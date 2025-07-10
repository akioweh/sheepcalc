module DeBruijn (
  DExpr (..),
  fromNamed,
  reindex,
  subst,
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

-- | variable substitution (capture-avoiding)
subst :: Int -> DExpr -> DExpr -> DExpr
subst t r = \case
  BoundVar v
    | v == t -> r
    | v > t -> BoundVar (v - 1)
    | otherwise -> BoundVar v
  fv@(FreeVar _) -> fv
  DAbs m -> DAbs (subst (t + 1) (reindex 1 r) m)
  DApp x y -> DApp (subst t r x) (subst t r y)

-- | re-index *free* variables by a given offset
reindex :: Int -> DExpr -> DExpr
reindex d = go 0
 where
  go i = \case
    -- i is the current amount of binders, the "level"
    BoundVar v
      | v >= i -> BoundVar (v + d)
      | otherwise -> BoundVar v -- bound variable
    fv@(FreeVar _) -> fv
    DAbs m -> DAbs (go (i + 1) m)
    DApp x y -> DApp (go i x) (go i y)
