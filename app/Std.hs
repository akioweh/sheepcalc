module Std (
  church,
  stddefs,
) where

import DeBruijn
import Syntax (Name)

-- | linearly constructs the Church Numeral representing n
church :: Int -> DExpr
church = DAbs . DAbs . go
 where
  go 0 = BoundVar 0
  go k = DApp (BoundVar 1) (go . pred $ k)

stddefs :: [(Name, String)]
stddefs =
  [ ("TRUE", "\\t f. t")
  , ("FALSE", "\\t f. f")
  , ("IF", "\\b t f. b t f")
  , ("NOT", "\\b. IF b FALSE TRUE")
  , ("AND", "\\x y. IF x (IF y TRUE FALSE) FALSE")
  , ("OR", "\\x y. IF (AND (NOT x) (NOT y)) FALSE TRUE")
  , ("SUCC", "\\n f x. f (n f x)")
  , ("PRED", "\\n f x. n (\\g h. h (g f)) (\\u. x) (\\u. u)")
  , ("ISZERO", "\\x. x (\\_. FALSE) TRUE")
  , ("ADD", "\\m n f x. m f (n f x)")
  , ("MUL", "\\x y. x (ADD y) 0")
  , ("SUB", "\\x y. y PRED x")
  , ("DIFF", "\\x y. ADD (SUB x y) (SUB y x)") -- absolute difference
  , ("EQ", "\\x y. ISZERO (DIFF x y)")
  , ("LE", "\\x y. ISZERO (SUB x y)")
  , ("LT", "\\x y. NOT (LE y x)")
  , ("FLIP", "\\f x y. f y x")
  , ("GT", "FLIP LT")
  , ("GE", "FLIP LE")
  ]
