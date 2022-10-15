require_relative './environment'
require_relative './native_functions'
require_relative './lox_function'

class Interpreter
  attr_reader :environment, :statements
  include NativeFunctions

  # might need to change to a @@ but we'll see
  @globals = Environment.new

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
    # Add native functions to the environment
    environment.define("clock", clock)
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
      evaluate(if_statement.then_branch)
      return
    end

    if_statement.elif_statements.each do |elif_statement|
      if evaluate(elif_statement.condition)
        evaluate(elif_statement.branch)
        return
      end
    end

    if if_statement.other_branch
      evaluate(if_statement.other_branch)
    end

    nil
  end

  def visit_call(call_exp)
    # will return a function object in the near future
    # I think I just need to define the global functions in here
    # and then find them 
    callee = evaluate(call_exp.callee)
    arguments = []
    call_exp.arguments.each { |arg| arguments << evaluate(arg) }

    if !callee.is_a?(LoxFunction)
      raise RuntimeError.new(call_exp.paren, "Can only call functions and classes.")
    end

    if call_exp.arguments.size != callee.arity
      raise RuntimeError.new(call_exp.paren,
        "Expected #{callee.arity} arguments but got #{call_exp.arguments.size}."
      )
    end
    
    # coerces callee into a loxcallabe with a call method but
    # I have to do something else in here
    # LoxCallable function = (LoxCallable)callee;
    # there's a missing step in here callee at this point is just an identifer
    # with the name of the function
    return callee.call(self, arguments);
  end

  def visit_logical(exp)
    left = evaluate(exp.left)

    if exp.operator.type == Token::Type::KEYWORDS['or']
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

  def visit_while(exp)
    while evaluate(exp.condition)
      evaluate(exp.body)
    end
    nil
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

  def visit_function(function_statement)
    function = LoxFunction.new(function_statement)
    environment.define(function_statement.name.lexeme, function)
  end

  def visit_print(print_statement)
    value = evaluate(print_statement.expression)
    puts value
    nil
  end

  def visit_block(block_statement)
    execute_block(block_statement.statements, Environment.new(environment))
  end

  def execute_block(statements, environment)
    previous_environment = environment

    begin
      @environment = environment
      statements.each { |statement| evaluate(statement) }
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
    when Token::Type::MODULO
      left % right
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
