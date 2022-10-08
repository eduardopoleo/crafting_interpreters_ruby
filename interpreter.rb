require_relative './environment'

class Interpreter
  attr_reader :environment, :statements

  class RuntimeError < StandardError
    attr_reader :token
  
    def initialize(token, message)
      @token = token
      super(message)
    end
  end

  def self.interpret(statements)
   new(statements).interpret
  end

  def initialize(statements)
    @statements = statements
    @environment = Environment.new
  end

  def interpret
    begin
      statements.each { |statement| evaluate(statement) }
    rescue RuntimeError => e
      Lox.display_error(e.token.line, nil, e.message)
    end
  end

  ### Visitor methods ###
  def visit_if(if_statement)
    if evaluate(if_statement.condition)
      execute(if_statement.then_branch)
    elsif if_statement.else_brach
      execute(if_statement.else_brach)
    end
    nil
  end

  def visit_logical(exp)
    left = evaluate(exp.left)

    if exp.operator.type == Token::TokenType::KEYWORDS['or']
      # return "true" if it's an or the first operand is true
      return left if left
    else
      # return "false" if it's an and and the first operand if false
      return left if !left
    end

    # if or and operand1 false
    # if and and operand2 true
    # both of these cases require checking on the right operand 
    return evaluate(exp.right)
  end
  
  def visit_assign(exp)
    value = evaluate(exp.value)
    environment.assign(exp.name.lexeme, value)
    value
  end

  def visit_expression(expression_statement)
    evaluate(expression_statement.expression)
    nil
  end

  def visit_print(print_statement)
    value = evaluate(print_statement.expression)
    puts value
    nil
  end

  def visit_block(block_statement)
    new_environment = Environment.new(environment)
    previous_environment = environment

    begin
      @environment = new_environment

      block_statement.statements.each do |statement|
        evaluate(statement)
      end
    ensure
      @environment = previous_environment
    end
  end

  # # E.g comparison → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
  def visit_binary(exp)
    # It's sort of like DFS we evaluate expressions deep until we've
    # evaluated the whole AST.
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
      raise RuntimeError.new(
        exp.operator,
        "Operands shoud be all strings or numbers"
      ) unless valid_addition_operands?(left, right)
      left + right
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

  def visit_grouping(exp)
    evaluate(exp.expression)
  end

  def visit_literal(exp)
    exp.value
  end

  # unary → ( "!" | "-" ) unary | primary ;
  def visit_unary(exp)
    right = evaluate(exp.right)
  
    case exp.operator.type
    when Token::Type::MINUS
      check_unary_operand(operator, right)
      -right
    when Token::Type::BANG # Weird thing.
      !!right
    end
  end

  def visit_var(statement)
    value = nil
    if !statement.initializer.nil?
      value = evaluate(statement.initializer)
    end

    environment.define(statement.name.lexeme, value)
    nil
  end

  def visit_variable(expression)
    environment.get(expression.name.lexeme)
  end

  # def execute is equivalent to this 
  def evaluate(statement)
    statement.accept(self)
  end

  def check_unary_operand(operator, operand)
    return if operand.is_a? Numeric
    raise RuntimeError.new(operator, "#{operator} operand must be a number.")
  end

  def check_binary_operands(operator, left, right)
    return if left.is_a?(Numeric) && right.is_a?(Numeric)
    raise RuntimeError.new(operator, "#{operator.lexeme}'s operands must be numbers.") 
  end

  def valid_addition_operands?(left, right)
    (left.is_a?(Numeric) && right.is_a?(Numeric)) ||
      (left.is_a?(String) && right.is_a?(String))
  end
end