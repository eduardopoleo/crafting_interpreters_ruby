class Environment
  attr_reader :values

  # TODO maybe move this to top level
  class RuntimeError < StandardError
    attr_reader :token
  
    def initialize(token, message)
      @token = token
      super(message)
    end
  end

  def initialize
    @values = {}
  end

  def assign(name, value)
    raise RuntimeError.new(
      name,
      "Variable not defined"
    ) unless values.has_key?(name.lexeme)
  
    values[name.lexeme] = value
  end

  def define(name, value)
    values[name] = value
  end

  def get(name)
    raise RuntimeError.new(
      name,
      "Variable not defined"
    ) unless values.has_key?(name)
    values[name]
  end
end