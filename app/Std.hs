module Std (
  church,
) where

import DeBruijin

-- | linearly constructs the Church Numeral representing n
church :: Int -> DExpr
church n = DAbs (DAbs (go n))
 where
  go 0 = BoundVar 0
  go k = DApp (BoundVar 1) (go . pred $ k)
