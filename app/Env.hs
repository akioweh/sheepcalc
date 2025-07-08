module Env (
  Env,
  resolve,
  church,
  fullEval,
  loadStringDef,
  loadStringDefs,
  loadDef,
) where

import Control.Monad (foldM)
import Data.Char (isDigit)
import Data.Map qualified as M
import DeBruijin
import Eval (eval)
import Parser (parseExpr)
import Std (church)
import Syntax
import Text.Parsec (ParseError)

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

-- | tries to add a list of definitions (as strings) to env
loadStringDefs :: Env -> [(Name, String)] -> Either ParseError Env
loadStringDefs = foldM loadStringDef

-- | tries to add a new definition (as string) to env
loadStringDef :: Env -> (Name, String) -> Either ParseError Env
loadStringDef env' (n, sexpr) = do
  nexpr <- parseExpr sexpr
  return $ M.insert n (fullEval env' nexpr) env'

-- | adds a new definition to env
loadDef :: Env -> (Name, NExpr) -> Env
loadDef env (n, nexpr) = M.insert n (fullEval env nexpr) env
