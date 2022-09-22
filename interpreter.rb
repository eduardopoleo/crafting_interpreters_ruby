class Interpreter
  class RuntimeError < StandardError; end
  # # E.g comparison → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
  def self.visit_binary(exp)
    left = evaluate(exp.left)
    right = evaluate(exp.right)

    case exp.operator.type
    when Token::MINUS
      check_binary_operands(operator, left, right)
      left - right
    when Token::SLASH
      check_binary_operands(operator, left, right)
      left / right
    when Token::STAR
      left * right
    when Token::PLUS
      left + right if valid_addition_operands?(left, right)
      raise RuntimeError.new("Operands shoud be all strings or numbers")
    when Token::GREATER
      check_binary_operands(operator, left, right)
      left > right
    when Token::GREATER_EQUAL
      check_binary_operands(operator, left, right)
      left >= right
    when Token::LESS
      check_binary_operands(operator, left, right)
      left < right
    when Token::LESS_EQUAL
      check_binary_operands(operator, left, right)
      left <= right
    when Token::BANG_EQUAL
      left != right
    when Token::EQUAL_EQUAL
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
    when Type::MINUS
      check_unary_operand(operator, right)
      -right
    when Type::BANG # Weird thing.
      !!right
    end
  end

  def self.evaluate(exp)
    exp.accept(self)
  end

  def self.check_unary_operand(operator, operand)
    return if operand.is_a? Numeric
    raise RuntimeError.new("#{operator} operand must be a number.")
  end

  def self.check_binary_operands(operator, left, right)
    return if left.is_a? Numeric && right.is_a? Numeric
    raise RuntimeError.new("#{operator} operands must be numbers.") 
  end

  def self.valid_addition_operands?(left, right)
    (left.is_a? Numeric && right.is_a? Numeric) ||
      (left.is_a? String && right.is_a? String)
  end
end