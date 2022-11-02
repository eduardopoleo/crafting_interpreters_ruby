require_relative './environment'
require_relative './native_functions'
require_relative './lox_function'
require_relative './lox_class'

class Interpreter
  attr_reader :environment, :statements, :globals, :locals
  include NativeFunctions

  class RuntimeError < StandardError
    attr_reader :token
  
    def initialize(token, message)
      @token = token
      super(message)
    end
  end

  class FunctionReturnException < StandardError
    attr_reader :value
  
    def initialize(value)
      @value = value
    end
  end

  class LoopBreakException < StandardError; end

  def initialize
    @environment = Environment.new

    # Add native functions to the environment
    @environment.define("clock", clock)
    @environment.define("readline", readline)
    @environment.define("coerce_to_i", coerce_to_i)
    @globals = @environment
    # Locals is a map between expression and distance
    # is the only resolve from the resolver operation
    # the idea is to calculate how many enclosing steps away is the variable to it's 
    # corresponding value. The distance is then used in the enviroment to recursively 
    # walk outwards until we hit the var value
    @locals = {}
  end

  def interpret(statements)
    @statements = statements
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
    begin
      while evaluate(exp.condition)
        evaluate(exp.body)
      end
    rescue LoopBreakException => e
      # Do nothing just exit out of the closest while loop
    end

    nil
  end
  
  def visit_assign(exp)
    value = evaluate(exp.value)
    distance = locals[exp]

    # Go up the chain of enclosing and set the value there
    if distance.nil?
      globals.assign(exp.name.lexeme, value)
    else
      environment.assign_at(distance, exp.name, value)
    end
    
    environment.assign(exp.name.lexeme, value)
    value
  end

  def visit_expression(expression_statement)
    evaluate(expression_statement.expression)
    nil
  end

  def visit_function(function_statement)
    # This creates a nested "chain" of enviroments
    # given that env.get searches the enclosing env this ensures that
    # if a value was defined in the enclosing envs it will be read
    function = LoxFunction.new(function_statement, environment)
    environment.define(function_statement.name.lexeme, function)
  end

  def visit_class(klass_statement)
    environment.define(klass_statement.name.lexeme, nil)
    methods = {}
    klass_statement.methods.each do |method|
      function = LoxFunction.new(method, environment)
      methods[method.name.lexeme] = function
    end
    klass = LoxClass.new(klass_statement.name.lexeme, methods)
    # this is weird why we use the token here and not the lexeme
    # why do we do the define and the assing in two steps?
    environment.assign(klass_statement.name.lexeme, klass)
  end

  def visit_call(call_exp)
    # this actually evaluates to visit_variable
    # which in turn fetches the value of the callable (class or function)
    # from the environment
    callee = evaluate(call_exp.callee)
    arguments = []
    call_exp.arguments.each { |arg| arguments << evaluate(arg) }

    if !callee.is_a?(LoxCallable)
      raise RuntimeError.new(call_exp.paren, "Can only call functions and classes.")
    end

    if call_exp.arguments.size != callee.arity
      raise RuntimeError.new(call_exp.paren,
        "Expected #{callee.arity} arguments but got #{call_exp.arguments.size}."
      )
    end
    return callee.call(self, arguments);
  end

  def visit_get(get)
    object = evaluate(get.object)
    return object.get(get.name) if object.is_a?(LoxInstance)
    raise RuntimeError.new(get.name, "Only Instance have properties.")
  end

  def visit_set(set)
    object = evaluate(set.object)
    if !object.is_a?(LoxInstance)
      raise RuntimeError.new(set.name, "Only Instance have properties.")
    end

    value = evaluate(set.value)
    object.set(set.name, value)
    return value
  end

  def visit_this(this)
    look_up_var(this, this.keyword)
  end

  def visit_print(print_statement)
    value = evaluate(print_statement.expression)
    puts value
    nil
  end

  def visit_return(return_statement)
    value = nil
    if !return_statement.value.nil?
      value = evaluate(return_statement.value)
    end

    raise FunctionReturnException.new(value)
  end

  def visit_break(_break)
    raise LoopBreakException
  end

  def visit_block(block_statement)
    execute_block(block_statement.statements, Environment.new(environment))
  end

  def execute_block(statements, block_environment)
    # the interpreter is the evaluator. Eveything gets evaluated based on the
    # environment of the interpreter. This env gets resetted every time right
    # before a function call. After the function / block is executed we restore
    # back the env
    #
    # fun functionA(a) {
    #   print a;
    # }

    # fun functionB(n) {
    #   functionA(4);
    #   print n;
    # }

    # functionB(2);

    # call functionB   => GlobEnv -> EnvB
    # call functionA   => EnvB -> EnvA
    # finish functionA => EnvA -> EnvB
    # finish functionB => EnvB -> GlobEnv
    previous_environment = @environment
    begin
      @environment = block_environment
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
      !right
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
    look_up_var(expression, expression.name)
  end

  def look_up_var(expression, name)
    distance = locals[expression]

    if distance != nil
      return environment.get_at(distance, name.lexeme)
    else
      return globals.get(name.lexeme)
    end
  end

  def visit_array(array)
    array.elements.map do |element|
      evaluate(element)
    end
  end

  def visit_array_accessor(accessor)
    array = evaluate(accessor.array)
    index = evaluate(accessor.index)

    return array[index] if accessor.operation == 'get'
    
    array[index] = evaluate(accessor.value_exp)
  end

  def visit_string_group(string_group)
    string = ''
    string_group.expressions.each do |exp|
      string = string + evaluate(exp).to_s
    end

    string
  end

  def evaluate(statement)
    statement.accept(self)
  end

  def resolve(exp, depth)
    locals[exp] = depth
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
