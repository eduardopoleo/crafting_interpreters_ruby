require_relative './lox_instance'

class LoxClass < LoxCallable
  attr_reader :name, :methods, :initializer, :superclass

  def initialize(name, superclass, methods)
    @name = name
    @methods = methods
    @superclass = superclass
    @initializer = find_method('init')
  end

  def find_method(name)
    return methods[name] if methods[name]

    if superclass
      return superclass.find_method(name)
    end

    nil
  end

  def call(interpreter, arguments)
    instance = LoxInstance.new(self)

    if !initializer.nil?
      initializer.bind(instance).call(interpreter, arguments)
    end
    
    instance
  end

  def arity
    initializer = find_method('init')
    return 0 if initializer.nil?
    initializer.arity
  end

  def to_s
    name
  end
end