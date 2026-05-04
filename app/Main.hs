module Main where

import Data.IORef (newIORef)
import Data.Map qualified as M
import System.Console.Haskeline (defaultSettings, runInputT, setComplete)
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
    ( \env0 -> do
        envRef <- newIORef env0
        let settings = setComplete (nameCompletion envRef) defaultSettings
        runInputT settings (repl envRef)
    )
    (loadStringDefs M.empty stddefs)
