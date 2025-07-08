module Repl (
  repl,
) where

import Data.Map.Strict qualified as M
import Data.Text.IO qualified as T
import Env (fullEval)
import Parser
import Pretty

repl :: IO ()
repl = loop M.empty
 where
  loop env = do
    putStr "sheepcalc|> "
    l <- getLine
    case parseLine l of
      Left e -> print e >> loop env
      Right s -> case s of
        SCmd "q" -> pure ()
        SCmd cmd -> putStrLn ("unknown command: " ++ cmd) >> loop env
        SDef n nexpr -> putStrLn ("defined: " ++ n) >> loop (M.insert n (fullEval env nexpr) env)
        SExpr nexpr -> (T.putStrLn . pretty . fullEval env) nexpr >> loop env
