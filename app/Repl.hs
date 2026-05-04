module Repl (
  repl,
  nameCompletion,
) where

import Control.Monad.IO.Class (liftIO)
import Data.Char (isSpace, isUpper, toLower)
import Data.IORef (IORef, modifyIORef', readIORef)
import Data.List (isPrefixOf)
import Data.Map qualified as M
import Data.Text.IO qualified as T
import System.Console.Haskeline (
  CompletionFunc,
  InputT,
  completeWord,
  getInputLine,
  outputStrLn,
  simpleCompletion,
 )

import Env (Env, fullEval, loadDef)
import Parser
import Pretty

-- | interpreter entry-point (self-recursive)
repl :: IORef Env -> InputT IO ()
repl envRef = do
  ml <- getInputLine "sheepcalc|> "
  case ml of
    Nothing -> return () -- Ctrl-D / EOF: exit gracefully
    Just l
      | all isSpace l -> repl envRef -- blank line: silent re-prompt
      | otherwise -> case parseLine l of
          Left e -> outputStrLn (show e) >> repl envRef
          Right s -> case s of
            SCmd "q" -> return ()
            SCmd cmd -> outputStrLn ("unknown command: " ++ cmd) >> repl envRef
            SDef n nexpr -> do
              liftIO (modifyIORef' envRef (\env -> loadDef env (n, nexpr)))
              outputStrLn ("defined: " ++ n)
              repl envRef
            SExpr nexpr -> do
              env <- liftIO (readIORef envRef)
              liftIO (T.putStrLn . pretty . fullEval env $ nexpr)
              repl envRef

-- | tab completion: matches prefixes against names defined in the current env (smart-case)
nameCompletion :: IORef Env -> CompletionFunc IO
nameCompletion envRef = completeWord Nothing wordBreakChars lookupNames
 where
  wordBreakChars = " ()\\.=\t\nλ" -- same chars the parser excludes from identifiers
  lookupNames prefix = do
    env <- readIORef envRef
    let matches = if any isUpper prefix then isPrefixOf else isPrefixOfCI
    return [simpleCompletion n | n <- M.keys env, prefix `matches` n]
  isPrefixOfCI p s = map toLower p `isPrefixOf` map toLower s
