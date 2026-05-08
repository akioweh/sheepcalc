module Repl (
  repl,
  nameCompletion,
) where

import Control.Concurrent (ThreadId, killThread, myThreadId, throwTo)
import Control.Concurrent.Async (asyncThreadId, waitCatch, withAsync)
import Control.Exception (evaluate, finally)
import Control.Monad.IO.Class (liftIO)
import Data.Char (isSpace, isUpper, toLower)
import Data.IORef (IORef, atomicWriteIORef, modifyIORef', newIORef, readIORef)
import Data.List (isPrefixOf)
import Data.Map qualified as M
import Data.Text.IO qualified as T
import System.Console.Haskeline (
  CompletionFunc,
  InputT,
  Interrupt (Interrupt),
  completeWord,
  getInputLine,
  handleInterrupt,
  outputStrLn,
  simpleCompletion,
 )
import System.Posix.Signals (Handler (Catch), installHandler, sigINT)

import Env (Env, fullEval, loadDef)
import Parser
import Pretty

{- | slot referencing the worker thread currently evaluating, or Nothing.
Used to stop compute on SIGINT.
-}
type WorkerSlot = IORef (Maybe ThreadId)

{- | install a unified SIGINT handler:
- if a worker is running (eval in progress), kill it
- otherwise, throw `Interrupt` to the main thread so haskeline can cancel input.
this replaces the default handler
-}
installInterruptHandler :: WorkerSlot -> ThreadId -> IO ()
installInterruptHandler slot mainTid = do
  _ <- installHandler sigINT (Catch handler) Nothing
  return ()
 where
  handler = do
    mtid <- readIORef slot
    case mtid of
      Just tid -> killThread tid
      Nothing -> throwTo mainTid Interrupt

{- | force a pure value on a worker thread; if the worker is killed by the
SIGINT handler, return Nothing. Otherwise return the value.
-}
runInterruptible :: WorkerSlot -> a -> IO (Maybe a)
runInterruptible slot x = withAsync (evaluate x) $ \wk -> do
  atomicWriteIORef slot (Just (asyncThreadId wk))
  res <- waitCatch wk `finally` atomicWriteIORef slot Nothing
  return (either (const Nothing) Just res)

-- | interpreter entry-point (self-recursive)
repl :: IORef Env -> InputT IO ()
repl envRef = do
  slot <- liftIO (newIORef Nothing)
  mainTid <- liftIO myThreadId
  liftIO (installInterruptHandler slot mainTid)
  go slot
 where
  -- handleInterrupt catches the Interrupt our handler throws when no worker is
  -- running (i.e. Ctrl-C during input editing). Eval-time Ctrl-C is handled
  -- inside runInterruptible by killing the worker thread.
  go slot = handleInterrupt (go slot) $ do
    ml <- getInputLine "sheepcalc|> "
    case ml of
      Nothing -> return () -- Ctrl-D / EOF: exit gracefully
      Just l
        | all isSpace l -> go slot -- blank line: silent re-prompt
        | otherwise -> case parseLine l of
            Left e -> outputStrLn (show e) >> go slot
            Right s -> case s of
              SCmd "q" -> return ()
              SCmd cmd -> outputStrLn ("unknown command: " ++ cmd) >> go slot
              SDef n nexpr -> do
                liftIO (modifyIORef' envRef (\env -> loadDef env (n, nexpr)))
                outputStrLn ("defined: " ++ n)
                go slot
              SExpr nexpr -> do
                env <- liftIO (readIORef envRef)
                mResult <- liftIO (runInterruptible slot (pretty (fullEval env nexpr)))
                case mResult of
                  Just t -> liftIO (T.putStrLn t)
                  Nothing -> outputStrLn "" -- newline after the kernel's `^C` echo
                go slot

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
