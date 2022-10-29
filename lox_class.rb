require_relative './lox_instance'

class LoxClass < LoxCallable
  attr_reader :name, :methods

  def initialize(name, methods)
    @name = name
    @methods = methods
  end

  def find_method(name)
    methods[name]
  end

  def call(interpreter, arguments)
    return LoxInstance.new(self)
  end

  def arity
    return 0
  end

  def to_s
    name
  end
end