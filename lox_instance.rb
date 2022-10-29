class LoxInstance
  attr_reader :klass, :fields

  def initialize(klass)
    @klass = klass
    @fields = {}
  end

  def get(name)
    return fields[name.lexeme] if fields[name.lexeme]
    method = klass.find_method(name.lexeme)
    return method if !method.nil?

    raise "Undefined property #{name}."
  end

  def set(name, value)
    fields[name.lexeme] = value
  end

  def to_s
    return klass.name + " instance"
  end
end