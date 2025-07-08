module Repl (
  repl,
) where

import Data.Text.IO qualified as T
import Env (Env, fullEval, loadDef)
import Parser
import Pretty

-- | interpreter entry-point (self-recursive)
repl :: Env -> IO ()
repl env = do
  putStr "sheepcalc|> "
  l <- getLine
  case parseLine l of
    Left e -> print e >> repl env
    Right s -> case s of
      SCmd "q" -> return ()
      SCmd cmd -> putStrLn ("unknown command: " ++ cmd) >> repl env
      SDef n nexpr -> do
        let env' = loadDef env (n, nexpr)
        putStrLn ("defined: " ++ n)
        repl env'
      SExpr nexpr -> (T.putStrLn . pretty . fullEval env) nexpr >> repl env
