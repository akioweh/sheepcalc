# `sheepcalc`

right now it already is a functional lambda calculus interpreter,
but i'll add more features to make it more usable.

## Usage

REPL-like interface.  
`>` is prompt.  
Each line of input can be either an expression or an interpreter command.  
Inputs are treated as expressions by default, unless it starts with a colon (`:`), in which case it is a command.

Expressions are "evaluated" by reducing to normal form.

**Expression syntax** support:

- `λ` or `\` for binder
- has sugar to allow multiple parameters per binder
- `.` separates parameters from body
- identifiers (variables) are arbitrary strings (not containing any of `()λ\.=`) delimited by spaces
  - IMPORTANT: you must insert spaces between adjacent but separate variables;
  - will add feature to toggle a "single char variable" parse mode
  - this means that literal numbers *are* identifiers
    - currently, they're automatically substituted for Church Numerals
- parentheses for grouping

There currently exists two **commands**:

- `:q` to quit (but ctrl-c also works)
- `:def <identifier> <expr>` to define a named expression (see below)

### Feature: Named Expressions

You can save expressions to identifiers that persist across prompts.  
In any future expressions (including the RHS of a definition), any occurrences of defined identifiers will be substituted with its expression, *before* any reduction takes place.
This also means that you can use named expressions in the RHS of definitions.
(Although note that identifiers are only substituted once, so you cannot define recursion like this.)

TIP: to check the definition of an identifier, just write it as a standalone expression in the prompt.

## Haskell stuff used

- ADTs (might see if i can make use of GADTs)
- loads of recursive structural traversal
- loads of pattern matching, case blocks, guards
- mondas, for control, short-circuiting, error propagation, IO, parsing, etc.
  - do blocks, operators like `>>=`, `<$>`, `<*>`, `>>`
- "lambdaCase" (nice point-free language feature)
- point-free style / composition
- modules
- cabal (build system)
- Parsec / grammar parser
- state-keeping
