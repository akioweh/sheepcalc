module Main where

import Repl
import System.IO

main :: IO ()
main = do
  hSetBuffering stdout NoBuffering
  repl
