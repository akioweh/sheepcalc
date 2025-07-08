module Env (
  Env,
  resolve,
  church,
  fullEval,
) where

import Data.Char (isDigit)
import Data.Map qualified as M
import DeBruijin
import Eval (eval)
import Std (church)
import Syntax

type Env = M.Map Name DExpr

{- | all-in-one evaluation from named expression to normal indexed expression
 including named substitution
-}
fullEval :: Env -> NExpr -> DExpr
fullEval env = eval . resolve env . fromNamed

-- | substitue free variables in expression using definitions in env
resolve :: Env -> DExpr -> DExpr
resolve env = go
 where
  go (FreeVar n) = case M.lookup n env of
    Just expr -> expr
    Nothing -> if all isDigit n then church (read n) else FreeVar n
  go (DAbs m) = DAbs (go m)
  go (DApp x y) = DApp (go x) (go y)
  go vb@(BoundVar _) = vb
