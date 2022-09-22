require_relative './expression'

class Parser
  class ParseError < StandardError; end

  attr_reader :tokens, :current

  def self.parse(tokens)
    new(tokens).parse
  end

  def initialize(tokens)
    @tokens = tokens
    @current = 0
  end

  def parse
    begin
      expression
    rescue Parser::ParseError => e
      # To be continued maybe with syncronize
      return nil
    end
  end

  # expression → equality ;
  def expression
    equality
  end

  # equality → comparison ( ( "!=" | "==" ) comparison )* ;
  def equality
    exp = comparison

    while match?([Token::Type::BANG_EQUAL, Token::Type::EQUAL_EQUAL]) do
      operator = peek
      advance
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
  def term
    exp = factor

    while match?([
      Token::Type::MINUS,
      Token::Type::PLUS
    ]) do
      operator = peek
      advance
      right = factor
      exp = Expression::Binary.new(exp, operator, right)
    end

    exp
  end

  # factor → unary ( ( "/" | "*" ) unary )* ;
  def factor
    exp = unary

    while match?([
      Token::Type::SLASH,
      Token::Type::STAR
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

    primary
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

    if match?(Token::Type::KEYWORDS['nil'])
      advance
      return Expression::Literal.new(nil) 
    end

    if match?(Token::Type::LEFT_PAREN)
      advance
      exp = expression

      raise_error("expected ) at #{current}") if !match?(Token::Type::RIGHT_PAREN)
        
      advance
      return Expression::Grouping.new(exp)
    end

    raise_error('Expected expression')
  end

  def match?(types)

    return false if at_end?

    types = Array(types)
    types.each do |type|
      return true if peek.type == type
    end

    false
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