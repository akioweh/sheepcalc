module Syntax (
  Name,
  NExpr (..),
) where

type Name = String

data NExpr
  = NVar Name
  | NAbs Name NExpr
  | NApp NExpr NExpr
  deriving (Eq, Show)
