module Eval (
  eval,
  step,
) where

import Control.Applicative ((<|>))
import DeBruijn

-- | evaluation through repeated beta-reduction
eval :: DExpr -> DExpr
eval e = maybe e eval $ step e

-- | single beta-reduction
step :: DExpr -> Maybe DExpr
step = \case
  DApp (DAbs m) x -> Just $ subst 0 x m -- directly reducible application
  DApp x y -> (flip DApp y <$> step x) <|> (DApp x <$> step y) -- try left, then right
  DAbs m -> DAbs <$> step m
  _ -> Nothing -- irreducible
