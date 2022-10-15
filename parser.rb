require_relative './expression'
require_relative './statement'

# Recursive Descent based on this rules

# program         → statement* EOF ;

# declaration     → fucDecl | var_declaration | statement 
# fucDecl         → "fun" function;
# function        → IDENTIFIER "(" parameters? ")" block;
# parameters      → IDENTIFIER ("," IDENTIFIER)*;
# var_declaration → "var" IDENTIFIER ( "=" expression )?;
# statement       → exprStmt | ifStmt | printStmt | while | block ;

# for_statment    → "for" "(" varDcl | expStm | ";" | expression? ";" | expression")" statement; 
# if_statement     → "if" "(" expression ")" ("elif" "(" expression ")" statement)*? ("else" statement)? ;
# printStmt       → "print" expression;
# block           → "{" declaration "}"
# exprStmt        → expression;
# whileStm        → "while" "(" expression ")" statement

# expression      → equality ;
# assignment      → IDENTIFIER "=" assignment | logic_or;
# logic_or        → logic_and ("or" logic_and)*;
# logic_and       → equality ("and" equality)*;
# equality        → comparison ( ( "!=" | "==" ) comparison )* ;
# comparison      → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
# term            → factor ( ( "-" | "+" ) factor )* ;
# factor          → unary ( ( "/" | "*" | "%" ) unary )* ;
# unary           → ( "!" | "-" ) unary | primary ;
# call            → primary ( "(" arguments? ")")*
# arguments       → expression ( "," expression)*;
# primary         → NUMBER | STRING | "true" | "false" | "nil" | "(" expression ")" | IDENTIFIER;

# convers a "dumb" list sequential tokens into expressions
# - each experession corresponds to a legal operation
# - expressions match the grammar hierarchy and rules
# - expressions compose on each other.
class Parser
  class ParseError < StandardError; end

  attr_reader :tokens, :current

  def self.parse(tokens)
    new(tokens).parse
  end

  def initialize(tokens)
    @tokens = tokens
    # We process the tokens 1 by 1.
    # this might be cuz we do not need look aheads (which I doubt)
    # or cuz the recursive nature of this.
    @current = 0
  end

  def parse
    begin
      statements = []
      
      # If the loops below finish means that we're found the end of the statement
      # then the rest of the outstanding tokens are gonna be dump into a new statement
      while !at_end? do
        statements << declaration # whatever is at the top of the grammar hierachy goes here.
      end
      statements
    rescue Parser::ParseError => e
      raise_error("#{e.message} at #{current}")
    end
  end

  def declaration
    return fun_declaration("function") if match!(Token::Type::KEYWORDS['fun'])
    return var_declaration if match!(Token::Type::KEYWORDS['var'])
  
    statement
  end

  def fun_declaration(kind)
    name = consume!(Token::Type::IDENTIFIER, "Expect #{kind} name.")
    consume!(Token::Type::LEFT_PAREN, "Expect, '( after #{kind} name.")
    parameters = []
    # This is not a while loop cuz... you wouldn't expect finding
    # the same st
    if !check(Token::Type::RIGHT_PAREN)
      begin
        if parameters.size >= 255
          raise_error("Can't have more than 255 paramenters")
        end
        parameters << consume!(Token::Type::IDENTIFIER, "Expect parameters name.")
      end while match!(Token::Type::COMMA)
    end

    consume!(Token::Type::RIGHT_PAREN, "Expect ') after parameters")
    consume!(Token::Type::LEFT_BRACE, "Expect '{' before #{kind} body")
    body = block
    Statement::Function.new(name, parameters, body)
  end

  def statement
    if match?(Token::Type::KEYWORDS['if'])
      advance
      return if_statement
    end

    if match?(Token::Type::KEYWORDS['print'])
      advance
      return print_statement
    end

    if match?(Token::Type::KEYWORDS['while'])
      advance
      return while_statement
    end

    if match?(Token::Type::KEYWORDS['for'])
      advance
      return for_statement
    end

    if match?(Token::Type::LEFT_BRACE)
      advance
      return Statement::Block.new(block)
    end

    expression_statement
  end
  
  def if_statement
    raise_error("Expected ( at #{current}") unless match?(Token::Type::LEFT_PAREN)
    advance
    condition = expression
    raise_error("Expected ( at #{current}") unless match?(Token::Type::RIGHT_PAREN)
    advance
    then_branch = statement

    elif_statements = []
    while match?(Token::Type::KEYWORDS['elif'])
      advance
      raise_error("Expected ( at #{peek.line}") unless match?(Token::Type::LEFT_PAREN)
      advance
      elif_condition = expression
      raise_error("Expected ) at #{peek.line}") unless match?(Token::Type::RIGHT_PAREN)
      advance
      elif_branch = statement
      elif_statements << Statement::Elif.new(elif_condition, elif_branch)
    end

    other_branch = nil
    if match?(Token::Type::KEYWORDS['else'])
      advance
      other_branch = statement
    end
    Statement::If.new(condition, then_branch, elif_statements, other_branch)
  end

  def print_statement
    # we advance to get to the actual token that we want to print
    value = expression
    # if after all the expression has been resolved we do not have a semicolon fail
    raise_error("expected ; at #{current}") unless match?(Token::Type::SEMICOLON)
    # we consume the semi colon token.
    advance
    Statement::Print.new(value)
  end

  def while_statement
    raise_error("expected ( at #{current}") unless match?(Token::Type::LEFT_PAREN)
    advance
    condition = expression

    raise_error("expected ) at #{current}") unless match?(Token::Type::RIGHT_PAREN)
    advance
    body = statement

    Statement::While.new(condition, body)
  end

  def for_statement
    # This will convert the for loop like this:
    # for (var i = 0; i < 10; i = i + 1)
    # print i;
  
    # into 
    # {
    #   var i = 0;
    #   while (i < 10) {
    #     print i;
    #     i = i + 1;
    #   }
    # }

    raise_error("expected ( the for") unless match?(Token::Type::LEFT_PAREN)
    advance
    initializer = nil

    if match?(Token::Type::SEMICOLON)
      advance
      initializer = nil
    elsif match?(Token::Type::KEYWORDS['var'])
      advance
      initializer = var_declaration
    else
      initializer = expression_statement
    end

    condition = nil
  
    if peek != Token::Type::SEMICOLON
      condition = expression
    end
    raise_error("expected ; the for") unless match?(Token::Type::SEMICOLON)
    advance

    increment = nil
    if peek != Token::Type::RIGHT_PAREN
      increment = expression
    end

    raise_error("expected ) the for") unless match?(Token::Type::RIGHT_PAREN)
    advance

    body = statement

    # if there is an increment e.g i = i + 1 we append it
    # to the last part of the body
    if increment
      body = Statement::Block.new([
        body,
        Statement::Expression.new(increment)
      ])
    end

    condition = Expression::Literal.new(true) unless condition

    # we have the top level codition i < 10
    # and the body with the increment appended at the end
    body = Statement::While.new(condition, body)

    # finally the initializer we add at the top if needed
    if initializer
      body = Statement::Block.new([initializer, body])
    end

    body
  end

  def block
    statements = []

    # the at_end is to prevent infinite loops! if an } is never found the loop will
    # never exit!
    while(!match?(Token::Type::RIGHT_BRACE) && !at_end?)
      statements << declaration
    end

    raise_error("Expected } at #{current}") unless match?(Token::Type::RIGHT_BRACE)
    advance
    statements
  end

  def expression_statement
    exp = expression
    raise_error("expected ) at #{current}") unless match?(Token::Type::SEMICOLON)
    advance
    Statement::Expression.new(exp)
  end

  # The order of these are taking from the order of precedence in C
  # Name	Operators	Associates
  # Equality	== !=	Left
  # Comparison	> >= < <=	Left
  # Term	- +	Left
  # Factor	/ *	Left
  # Unary	! -	Right

  def var_declaration
    raise_error('Expected var identifier') unless match?(Token::Type::IDENTIFIER)
    name = peek
    advance
    initializer = nil
    if match?(Token::Type::EQUAL)
      advance
      initializer = expression
    end
    raise_error('Expected ; to finish statement') unless match?(Token::Type::SEMICOLON)
    advance
    Statement::Var.new(name, initializer)
  end

  def expression
    assignment
  end

  # Assignment is rigth associative
  # a = (b = c) is correct cuz the R-value of a = makes sense
  # (a = b) = c is not correct cuz it does not provide a place to store c
  def assignment
    exp = or_exp

    if match?(Token::Type::EQUAL)
      equals = peek
      advance
      # This recursion loop ensures that this becomes right associative
      value = assignment

      if exp.is_a?(Expression::Variable)
        name = exp.name
        return Expression::Assign.new(name, value)
      end

      raise_error("=, Invalid assignment target")
    end

    return exp
  end

  def or_exp
    exp = and_exp

    while(match?(Token::Type::KEYWORDS['or']))
      operator = peek
      advance
      right = and_exp
      exp = Expression::Logical.new(exp, operator, right)
    end

    exp
  end

  def and_exp
    exp = equality

    while(match?(Token::Type::KEYWORDS['and']))
      operator = peek
      advance
      right = equality
      exp = Expression::Logical.new(exp, operator, right)
    end

    exp
  end

  # equality → comparison ( ( "!=" | "==" ) comparison )* ;
  def equality
    exp = comparison

    # The reason for the while loops once you get in here the first time
    # all the other symbols will get resolved in the higher precedence methods.
    # before you get back up. Then if you're here again it means that you're 
    # either done or that you stumble upon another  ==, !=
    while match?([Token::Type::BANG_EQUAL, Token::Type::EQUAL_EQUAL]) do
      # store the != 
      operator = peek
      # consume it
      advance
      # get ahold of the right end of the expression
      right = comparison
      exp = Expression::Binary.new(exp, operator, right)
    end

    exp
  end

  # comparison → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
  def comparison
    exp = term

    while match?([
      Token::Type::GREATER,
      Token::Type::GREATER_EQUAL,
      Token::Type::LESS,
      Token::Type::LESS_EQUAL
    ]) do
      operator = peek
      advance
      right = term
      exp = Expression::Binary.new(exp, operator, right)
    end

    exp
  end

  # term → factor ( ( "-" | "+" ) factor )* ;
  # Left Associative
  # should be left associative 
  # 5 - 1 - 2 -----> (5 - 1) - 2 => 2 (CORRECT)
  def term
    exp = factor

    while match?([
      Token::Type::MINUS,
      Token::Type::PLUS
    ])
      operator = peek
      advance
      # Accumulates, as it accumulates expressions it stores them
      # accumulated exp get included to the left
      right = factor
      exp = Expression::Binary.new(exp, operator, right)
    end

    exp
  end

  # exp -> literal 5

  # LOOP 1
  # operator -> -
  # right 1
  # exp1 -> 5 - 1

  # LOOP 2
  # operator -> -
  # right 2
  # exp -> exp1 - 2 -> (5-1) - 2

  # It's left associative becuase the previous expression accumulates 
  # and then gets feed back into the next expression

  # result is the last calculated exp 


  # Right associative
  # 5 - 1 - 2 -----> 5 - (1 - 2) => 6 (WRONG)
  # def term
  #   exp = factor

  #   if match?([
  #     Token::Type::MINUS,
  #     Token::Type::PLUS
  #   ])
  #     operator = peek
  #     advance
  #     The recursion makes it so that is DFS, it builds the expression on the right
  #     Accumulated exp get included on the right
  #     right = term
  #     exp = Expression::Binary.new(exp, operator, right)
  #   end

  #   exp
  # end

  # RECURSE LOOP 1
  # exp 5
  # operator -
  # PENDING loop
  # right -> exp1
  # exp2 -> 5 - exp1 -> 5 - (1 - 2)

  # RECURSE LOOP 2
  # exp 1
  # operator -
  # PENDING loop
  # right -> 2
  # exp1 -> 1 - 2

  # RECURSE LOOP 3
  # exp -> 2
  # returns

  # factor → unary ( ( "/" | "*" ) unary )* ;
  def factor
    exp = unary

    while match?([
      Token::Type::SLASH,
      Token::Type::STAR,
      Token::Type::MODULO
    ]) do
      operator = peek
      advance
      right = unary
      exp = Expression::Binary.new(exp, operator, right)
    end

    exp
  end

  # unary → ( "!" | "-" ) unary | primary ;
  def unary
    if match?([Token::Type::BANG, Token::Type::MINUS])
      operator = peek.type
      advance
      right = primary

      return Expression::Unary.new(operator, right)
    end

    call
  end

  # Same as other type of expressions we need to recurse to be able to catch all
  # function calls
  MAX_NUMBER_OF_ARGUMENTS = 255
  def call
    exp = primary
    # this is the same deal as the other expressions.
    # this while loop allows us to target ALL funtion calls in the expression
    while match!(Token::Type::LEFT_PAREN)
      arguments = []
      if !check(Token::Type::RIGHT_PAREN)
        # Iterate until you run out of commas the first loop does not require a comma.
        begin
          raise_error("Too many arguments at #{current}") if arguments.size >= MAX_NUMBER_OF_ARGUMENTS
          arguments << expression
        end while(match!(Token::Type::COMMA))
      end

      consume!(Token::Type::RIGHT_PAREN, "Expected ) at #{current}")
      # Current token contains the closing param
      exp = Expression::Call.new(exp, previous, arguments)
    end
# require 'pry'; binding.pry
    exp
  end

  # primary → NUMBER | STRING | "true" | "false" | "nil" | "(" expression ")" ;
  def primary
    if match?([Token::Type::NUMBER, Token::Type::STRING])
      exp = Expression::Literal.new(peek.literal)
      advance
      return exp
    end

    if match?(Token::Type::KEYWORDS['true'])
      advance
      return Expression::Literal.new(true) 
    end

    if match?(Token::Type::KEYWORDS['false'])
      advance
      return Expression::Literal.new(false)
    end

    if match!(Token::Type::IDENTIFIER)
      return Expression::Variable.new(previous)
    end

    if match!(Token::Type::KEYWORDS['nil'])
      return Expression::Literal.new(nil) 
    end

    if match!(Token::Type::LEFT_PAREN)
      exp = expression
      consume!(Token::Type::RIGHT_PAREN, "expected ) at #{current}")
      return Expression::Grouping.new(exp)
    end

    raise_error('Expected expression')
  end

  ### utility methods ###
  def match?(types)

    return false if at_end?

    types = Array(types)
    types.each do |type|
      return true if peek.type == type
    end

    false
  end

  def match!(types)
    return false if at_end?

    types = Array(types)

    types.each do |type|
      if peek.type == type
        advance; return true
      end
    end
    
    false
  end

  def check(types)
    types = Array(types)

    types.each do |type|
      return true if peek.type == type
    end
    
    false
  end

  def consume!(type, error)
    raise_error("expected #{type} at #{current}") unless match!(type)

    previous
  end

  def previous
    tokens[current - 1]
  end

  def raise_error(message)
    Lox.display_error(peek.line, peek.lexeme, message)
    raise ParseError.new(message)
  end

  def at_end?
    return true if peek.type == Token::Type::EOF
  end

  def peek
    tokens[current]
  end

  def advance
    @current += 1
  end
end

__END__
Check if the passed type is correct otherwise throw an error

private Token consume(TokenType type, String message) {
  if (check(type)) return advance();

  throw error(peek(), message);
}

private boolean match(TokenType... types) {
  for (TokenType type : types) {
    if (check(type)) {
      advance();
      return true;
    }
  }

  return false;
}