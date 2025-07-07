module DeBruijin (
  DExpr (..),
  fromNamed,
) where

import Data.Map.Strict qualified as M
import Syntax

-- | best kind of binary tree
data DExpr
  = BoundVar Int
  | FreeVar String
  | DAbs DExpr
  | DApp DExpr DExpr
  deriving (Eq, Show)

-- | convert to DeBrujin indexing
fromNamed :: NExpr -> DExpr
fromNamed = go M.empty
 where
  go mem = \case
    NVar v -> case M.lookup v mem of
      Just i -> BoundVar i
      Nothing -> FreeVar v
    NAbs p m -> DAbs (go (M.insert p 0 (M.map (+ 1) mem)) m)
    NApp x y -> DApp (go mem x) (go mem y)
