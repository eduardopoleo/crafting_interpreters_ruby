require_relative './environment'
require_relative './interpreter'

class LoxFunction < LoxCallable
  attr_reader :declaration, :closure, :is_initializer

  def initialize(declaration, closure, is_initializer)
    @declaration = declaration
    @closure = closure
    @is_initializer = is_initializer
  end

  def arity
    declaration.params.size
  end

  # binds the function to it's corresponding instance
  def bind(instance)
    enviroment = Environment.new(closure)
    enviroment.define('this', instance)
    # This seems like a stupid indirection
    # why don't we just bind this to the closure directly when extract
    # the method from the instace get?
    self.class.new(declaration, enviroment, is_initializer)
  end

  def call(interpreter, arguments)
    environment = Environment.new(closure)
    for i in 0...declaration.params.size
      environment.define(declaration.params[i].lexeme, arguments[i])
    end

    begin
      interpreter.execute_block(declaration.body, environment)
    rescue Interpreter::FunctionReturnException => result
      return closure.get_at(0, 'this') if is_initializer
      return result.value
    end

    return closure.get_at(0, 'this') if is_initializer
  end

  def to_s
    "<fn #{declaration.name.lexeme} >";
  end
end