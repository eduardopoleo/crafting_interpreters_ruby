program        → statement* EOF ;
statement      → exprStmt | printStmt ;
exprStmt       → expression ";" ;
printStmt      → "print" expression ";" ;

What expressions does a language have?

- Literal values (strings, numbers) and statements
"a string", 4, var, let
- Unary expressions
!5, !8, -3
- Binary expressions
5 + 2, 5 > 4,
- Parens
()

This can be translated to productions such as:

expression -> Literal | Unary | Binary | Grouping

literal  -> NUMBER | STRING | "true" | "false" | "nil"
unary    -> (! | -) Unary
binary   -> Expression Operator Expression
grouping -> "(" Expression ")"
operator -> = | == | != | >= | <= | - | + | * | / | 

The problem with these productions are ambiguous 
- Associativity
- Precedence

For instance the following expression:
6 - 3 - 1 => (6 - 3) - 1  => 2  Correct because the - operator is left associative ?
6 - 3 - 1 => 6 - (3 - 1)  => 4

Or this

6 / 3 + 2 -> 6 / (3 + 2) -> 6 / 5
6 / 3 + 2 -> (6 / 3) + 2 -> 4 -> Correct because / has precedence over + 

Here are the rules for C

Name	       Operators	  Associates
Equality	     == !=	      Left
Comparison	  > >= < <=	    Left
Term	          - +	        Left
Factor	       / *	        Left
Unary	         ! -	        Right


With that and the previous productions we can derive the following rules

expression -> equality
equality   -> comparison ( ( "==" | "!=" ) comparison )*
comparison -> term ( ( > | >= | < | <= ) term )*
term       -> factor ( ( "-" | "+" ) factor )*
factor     -> unary (("/" | "*") unary)*
unary      -> (! | -) unary | primary
primary    -> NUMBER | STRING | "true" | "false" | "nil" | "(" expression ")"

These productions lend themselves well to a recursive descent algo
Each production must reference the production immdiately higher
While loop ensure that we can handle multiple occurances of the same time of symbol

TODO, the expression vs statement. Sometimes it's hard to know whether a takes a token or a string