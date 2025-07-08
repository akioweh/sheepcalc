module Repl (repl) where

import Control.Monad (forever)
import Data.Text.IO qualified as T
import DeBruijin
import Eval
import Parser
import Pretty
import System.Exit (exitSuccess)

repl :: IO ()
repl = forever $ do
  putStr "> "
  getLine >>= \case
    ":q" -> exitSuccess
    nexpr -> either print (T.putStrLn . pretty . eval . fromNamed) (parseExpr nexpr)
