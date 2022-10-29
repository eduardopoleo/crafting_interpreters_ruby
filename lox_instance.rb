class LoxInstance
  attr_reader :klass

  def initialize(klass)
    @klass = klass
  end

  def to_s
    return klass.name + " instance"
  end
end