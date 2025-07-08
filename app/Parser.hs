module Parser (
  parseExpr,
  parseLine,
  Stmt (..),
) where

import Control.Applicative (some)
import Syntax
import Text.Parsec
import Text.Parsec.String (Parser)

data Stmt
  = SExpr NExpr
  | SDef Name NExpr
  | SCmd String

parseLine :: String -> Either ParseError Stmt
parseLine = parse (spaces *> stmt <* eof) "<repl>"

parseExpr :: String -> Either ParseError NExpr
parseExpr = parse (spaces *> expr <* eof) "<repl>"

lexeme :: Parser a -> Parser a
lexeme p = p <* spaces

symbol :: Char -> Parser Char
symbol = lexeme . char

keyword :: String -> Parser String
keyword = lexeme . string

stmt :: Parser Stmt
stmt =
  try def
    <|> cmd
    <|> SExpr
    <$> expr

cmd :: Parser Stmt
cmd = SCmd <$> (symbol ':' *> many1 (noneOf "\n"))

def :: Parser Stmt
def = do
  _ <- keyword ":def"
  ident <- identifier
  SDef ident <$> expr

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
identifier = lexeme (many1 (noneOf " ()\\.=\n\tλ")) <?> "variable name"
