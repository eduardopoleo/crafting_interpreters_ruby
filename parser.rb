require_relative './expression'

class Parser
  attr_reader :tokens, :current

  def self.parse(tokens)
    new(tokens).parse
  end

  def initialize(tokens)
    @tokens = tokens
    @current = 0
  end

  def parse
    expression
  end

  # expression → equality ;
  def expression
    equality
  end

  # equality → comparison ( ( "!=" | "==" ) comparison )* ;
  def equality
    left = comparison

    while match?([Token::Type::BANG_EQUAL, Token::Type::EQUAL_EQUAL]) do
      operator = peek
      advance
      right = comparison
    end

    Expression::Binary.new(left, operator, right)
  end

  # comparison → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
  def comparison
    left = term

    while match?([
      Token::Type::GREATER,
      Token::Type::GREATER_EQUAL,
      Token::Type::LESS,
      Token::Type::LESS_EQUAL
    ]) do
      operator = peek
      advance
      right = term
    end

    Expression::Binary.new(left, operator, right)
  end

  # term → factor ( ( "-" | "+" ) factor )* ;
  def term
    left = factor

    while match?([
      Token::Type::MINUS,
      Token::Type::PLUS
    ]) do
      operator = peek
      advance
      right = factor
    end

    Expression::Binary.new(left, operator, right)
  end

  # factor → unary ( ( "/" | "*" ) unary )* ;
  def factor
    left = unary

    while match?([
      Token::Type::SLASH,
      Token::Type::STAR
    ]) do
      operator = peek
      advance
      right = unary
    end

    Expression::Binary.new(left, operator, right)
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
      advance

      raise "expecting ) and not found" unless match?(Token::Type::RIGHT_PAREN)

      return Expression::Grouping.new(exp)
    end
  end

  def match?(types)
    return false if at_end?
    
    types = Array(types)
    types.each do |type|
      return true if peek.type == type
    end

    false
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