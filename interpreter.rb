class Interpreter
  class RuntimeError < StandardError
    attr_reader :token
  
    def initialize(token, message)
      @token = token
      super(message)
    end
  end

  def self.interpret(exp)
    begin
      evaluate(exp)
    rescue RuntimeError => e
      Lox.display_error(e.token.line, nil, e.message)
    end
  end
  # # E.g comparison → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
  def self.visit_binary(exp)
    left = evaluate(exp.left)
    right = evaluate(exp.right)

    case exp.operator.type
    when Token::Type::MINUS
      check_binary_operands(exp.operator, left, right)
      left - right
    when Token::Type::SLASH
      check_binary_operands(exp.operator, left, right)
      left / right
    when Token::Type::STAR
      left * right
    when Token::Type::PLUS
      left + right if valid_addition_operands?(left, right)
      raise RuntimeError.new(exp.operator, "Operands shoud be all strings or numbers")
    when Token::Type::GREATER
      check_binary_operands(exp.operator, left, right)
      left > right
    when Token::Type::GREATER_EQUAL
      check_binary_operands(exp.operator, left, right)
      left >= right
    when Token::Type::LESS
      check_binary_operands(exp.operator, left, right)
      left < right
    when Token::Type::LESS_EQUAL
      check_binary_operands(exp.operator, left, right)
      left <= right
    when Token::Type::BANG_EQUAL
      left != right
    when Token::Type::EQUAL_EQUAL
      left == right
    end
  end

  def self.visit_grouping(exp)
    evaluate(exp.expression)
  end

  def self.visit_literal(exp)
    exp.value
  end

  # unary → ( "!" | "-" ) unary | primary ;
  def self.visit_unary(exp)
    right = evaluate(exp.right)
  
    case exp.operator.type
    when Token::Type::MINUS
      check_unary_operand(operator, right)
      -right
    when Token::Type::BANG # Weird thing.
      !!right
    end
  end

  def self.evaluate(exp)
    exp.accept(self)
  end

  def self.check_unary_operand(operator, operand)
    return if operand.is_a? Numeric
    raise RuntimeError.new(operator, "#{operator} operand must be a number.")
  end

  def self.check_binary_operands(operator, left, right)
    return if left.is_a?(Numeric) && right.is_a?(Numeric)
    raise RuntimeError.new(operator, "#{operator} operands must be numbers.") 
  end

  def self.valid_addition_operands?(left, right)
    (left.is_a?(Numeric) && right.is_a?(Numeric)) ||
      (left.is_a?(String) && right.is_a?(String))
  end
end