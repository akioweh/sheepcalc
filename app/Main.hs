module Main where

import Data.Map qualified as M
import Env
import Repl
import Std
import System.IO

main :: IO ()
main = do
  hSetBuffering stdout NoBuffering
  -- load stddefs
  either
    ( \e -> do
        putStrLn "Error loading standard definitions: "
        print e
    )
    repl
    (loadStringDefs M.empty stddefs)
