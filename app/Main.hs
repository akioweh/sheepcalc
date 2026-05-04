module Main where

import Data.Map qualified as M
import System.Console.Haskeline (defaultSettings, runInputT)
import System.IO

import Env
import Repl
import Std

main :: IO ()
main = do
  hSetBuffering stdout NoBuffering
  -- load stddefs
  either
    ( \e -> do
        putStrLn "Error loading standard definitions: "
        print e
    )
    (runInputT defaultSettings . repl)
    (loadStringDefs M.empty stddefs)
