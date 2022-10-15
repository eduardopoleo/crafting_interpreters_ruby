require_relative './environment'

class LoxFunction < LoxCallable
  attr_reader :declaration

  def initialize(declaration)
    @declaration = declaration
  end

  def arity
    declaration.params.size
  end

  def call(interpreter, arguments)
    environment = Environment.new(interpreter.environment)

    for i in 0...declaration.params.size
      environment.define(declaration.params[i].lexeme, arguments[i])
    end

    interpreter.execute_block(declaration.body, environment)
  end

  def to_s
    "<fn #{declaration.name.lexeme} >";
  end
end