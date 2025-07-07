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
  DApp x y -> fmap (`DApp` y) (step x) -- reduce left first
  DAbs m -> DAbs <$> step m
  _ -> Nothing -- signal irreducibility

-- | variable substitution (capture-avoiding)
subst :: Int -> DExpr -> DExpr -> DExpr
subst t r = \case
  BoundVar v
    | v == t -> r
    | v > t -> BoundVar (v - 1)
    | otherwise -> BoundVar v
  FreeVar v -> FreeVar v
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
    FreeVar v -> FreeVar v
    DAbs m -> DAbs (go (i + 1) m)
    DApp x y -> DApp (go i x) (go i y)
