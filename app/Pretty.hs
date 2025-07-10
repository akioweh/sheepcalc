{-# LANGUAGE OverloadedStrings #-}

module Pretty (pretty) where

import Data.Text (Text)
import DeBruijn
import TextBuilder

-- | pretty printer
pretty :: DExpr -> Text
pretty = toText . go 0
 where
  go :: Int -> DExpr -> TextBuilder
  go _ (BoundVar v) = string . show $ v
  go _ (FreeVar v) = string v
  go p (DAbs m) = _paren p 1 $ "λ." <> go 0 m
  go p (DApp x y) = _paren p 2 $ go 2 x <> " " <> go 3 y
  _paren p q t
    | p > q = "(" <> t <> ")"
    | otherwise = t
