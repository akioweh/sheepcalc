module Repl (
  repl,
) where

import Control.Monad.IO.Class (liftIO)
import Data.Char (isSpace)
import Data.Text.IO qualified as T
import System.Console.Haskeline (InputT, getInputLine, outputStrLn)

import Env (Env, fullEval, loadDef)
import Parser
import Pretty

-- | interpreter entry-point (self-recursive)
repl :: Env -> InputT IO ()
repl env = do
  ml <- getInputLine "sheepcalc|> "
  case ml of
    Nothing -> return () -- Ctrl-D / EOF: exit gracefully
    Just l
      | all isSpace l -> repl env -- blank line: silent re-prompt
      | otherwise -> case parseLine l of
          Left e -> outputStrLn (show e) >> repl env
          Right s -> case s of
            SCmd "q" -> return ()
            SCmd cmd -> outputStrLn ("unknown command: " ++ cmd) >> repl env
            SDef n nexpr ->
              let env' = loadDef env (n, nexpr)
               in outputStrLn ("defined: " ++ n) >> repl env'
            SExpr nexpr -> liftIO (T.putStrLn . pretty . fullEval env $ nexpr) >> repl env
