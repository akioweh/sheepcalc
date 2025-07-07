# `sheepcalc`

right now it already is a functional lambda calculus interpreter,
but i'll add more features to make it more usable.

## Usage

REPL-like interface.  
`>` is prompt.
Each line of input is "evaluated" by reducing to normal form.

Syntax support:

- `λ` or `\` for binder
- has sugar to allow multiple parameters per binder
- `.` separates parameters from body
- identifiers (variables) are strings starting with a letter and delimited by spaces
  - IMPORTANT: you must insert spaces between adjacent but separate variables;
  - will add feature to toggle a "single char variable" parse mode
- parentheses for grouping

## Haskell stuff used

- ADTs (might see if i can make use of GADTs)
- loads of recursive structural traversal
- loads of pattern matching, case blocks, guards
- mondas, for control, short-circuiting, error propagation, IO, parsing, etc.
  - do blocks, operators like `>>=`, `<$>`, `<*>`
- "lambdaCase" (nice point-free language feature)
- point-free style
- modules
- cabal (build system)
- Parsec / grammar parser
