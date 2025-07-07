module Parser (parseExpr) where

import Control.Applicative (some)
import Syntax
import Text.Parsec
import Text.Parsec.String (Parser)

-- | this does what it does
parseExpr :: String -> Either ParseError NExpr
parseExpr = parse (spaces *> expr <* eof) "<repl>"

lexeme :: Parser a -> Parser a
lexeme p = p <* spaces

symbol :: Char -> Parser Char
symbol = lexeme . char

expr :: Parser NExpr
expr = chainl1 atom (pure NApp)

atom :: Parser NExpr
atom =
  abstraction
    <|> var
    <|> between (symbol '(') (symbol ')') expr

abstraction :: Parser NExpr
abstraction = do
  _ <- lexeme $ oneOf "\\λ"
  vs <- some $ lexeme identifier -- we're nice so we allow multiple parameters
  _ <- symbol '.'
  m <- expr
  pure (foldr NAbs m vs)

var :: Parser NExpr
var = NVar <$> identifier

identifier :: Parser String
identifier = lexeme ((:) <$> letter <*> many (alphaNum <|> char '\'')) <?> "variable"
