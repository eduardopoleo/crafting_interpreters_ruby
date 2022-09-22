class Interpreter
  # # E.g comparison → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
  def self.visit_binary(exp)
    left = evaluate(exp.left)
    right = evaluate(exp.right)

    case exp.operator.type
    when Token::MINUS
      left - right
    when Token::SLASH
      left / right
    when Token::STAR
      left * right
    when Token::PLUS
      left + right
    when Token::GREATER
      left > right
    when Token::GREATER_EQUAL
      left >= right
    when Token::LESS
      left < right
    when Token::LESS_EQUAL
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
      -right
    when Type::BANG # Weird thing.
      !!right
    end
  end

  def self.evaluate(exp)
    exp.accept(self)
  end
end