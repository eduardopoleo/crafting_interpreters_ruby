require_relative './environment'
require_relative './interpreter'

class LoxFunction < LoxCallable
  attr_reader :declaration

  def initialize(declaration)
    @declaration = declaration
  end

  def arity
    declaration.params.size
  end

  def call(interpreter, arguments)
    environment = Environment.new(interpreter.globals)
    for i in 0...declaration.params.size
      environment.define(declaration.params[i].lexeme, arguments[i])
    end

    begin
      interpreter.execute_block(declaration.body, environment)
    rescue Interpreter::FunctionReturnException => result
      return result.value
    end
  end

  def to_s
    "<fn #{declaration.name.lexeme} >";
  end
end