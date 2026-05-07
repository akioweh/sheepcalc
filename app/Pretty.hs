{-# LANGUAGE OverloadedStrings #-}

module Pretty (pretty) where

import Data.Text (Text)
import TextBuilder

import DeBruijn

-- | precedence levels — controls when subterms get parenthesized
topP, lamP, appP, argP :: Int
topP = 0 -- top-level / inside a lambda body
lamP = 1 -- abstraction `λ. m`
appP = 2 -- application `f x`
argP = 3 -- right-hand side of an application

-- | pretty printer with Church numeral detection
pretty :: DExpr -> Text
pretty = toText . pstr . walk topP

{- | result of one bottom-up walk
`num` is `Just n` iff this expression is a Church body chain `1 (1 ... (1 0))` of length n
`pstr`  is the pretty-printed form
-}
data Walk = Walk {num :: Maybe Int, pstr :: TextBuilder}

-- | Church numeral extraction thing (linear time)
walk :: Int -> DExpr -> Walk
walk _ (BoundVar 0) = Walk (Just 0) "0"
walk _ (BoundVar v) = Walk Nothing (string (show v))
walk _ (FreeVar v) = Walk Nothing (string v)
walk p (DApp f x) =
  let wf = walk appP f
      wx = walk argP x
      ch = case f of
        BoundVar 1 -> succ <$> num wx
        _ -> Nothing
   in Walk ch (_paren p appP (pstr wf <> " " <> pstr wx))
walk p (DAbs (DAbs body)) =
  let wb = walk topP body
   in Walk Nothing $ case num wb of
        Just n -> string (show n)
        Nothing -> _paren p lamP ("λ.λ." <> pstr wb)
walk p (DAbs m) =
  Walk Nothing (_paren p lamP ("λ." <> pstr (walk topP m)))

_paren :: Int -> Int -> TextBuilder -> TextBuilder
_paren p q t
  | p > q = "(" <> t <> ")"
  | otherwise = t
