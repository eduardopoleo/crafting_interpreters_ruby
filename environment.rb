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

  def get_at(distance, name)
    ancestor(distance).values[name];
  end

  def assign_at(distance, name, value)
    ancestor(distance).values[name.lexeme] = value
  end

  def ancestor(distance)
    enviroment = self
    for i in (0...distance)
      environment = environment.enclosing
    end

    enviroment
  end

  def get(name)
    return values[name] if values.has_key?(name)

    return enclosing.get(name) if !enclosing.nil?

    raise RuntimeError.new(
      name,
      "Variable #{name} not defined"
    )
  end

  def assign(name, value)
    return values[name] = value if values.has_key?(name)

    return enclosing.define(name, value) if !enclosing.nil?

    raise RuntimeError.new(
      name,
      "Variable #{name} not defined"
    )
  end
end
