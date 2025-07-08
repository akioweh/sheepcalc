module Eval (
  eval,
  step,
) where

import DeBruijin

-- | evaluation through repeated beta-reduction
eval :: DExpr -> DExpr
eval e = maybe e eval (step e)

-- | single beta-reduction
step :: DExpr -> Maybe DExpr
step = \case
  DApp (DAbs m) x -> Just (subst 0 x m) -- directly reducible application
  DApp x y -> case step x of
    Just x' -> Just (DApp x' y) -- try reducing left side first
    Nothing -> DApp x <$> step y
  DAbs m -> DAbs <$> step m
  _ -> Nothing -- irreducible
