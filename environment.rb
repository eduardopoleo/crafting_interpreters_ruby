class Environment
  # TODO maybe move this to top level
  class RuntimeError < StandardError
    attr_reader :token
  
    def initialize(token, message)
      @token = token
      super(message)
    end
  end

  attr_reader :values, :enclosing

  def initialize(enclosing = nil)
    # Enclosing is another environment!
    # Every environment has it's values and a reference to the next
    @enclosing = enclosing
    @values = {}
  end

  def define(name, value)
    values[name] = value
  end

  def get(name)
    return[name.lexeme] if values.has_key?(name.lexeme)

    return enclosing.get(name.lexeme) if !enclosing.nil?

    raise RuntimeError.new(
      name,
      "Variable not defined"
    )
  end

  def assign(name, value)
    values[name.lexeme] = value if values.has_key?(name.lexeme)

    enclosing.assign(name, value) if !enclosing.nil?

    raise RuntimeError.new(
      name,
      "Variable not defined"
    )
  end
end
