# Generated file with all AST expressions type

class Expression
  class Binary
    attr_reader :left, :operator, :right

    def initialize(left, operator, right)
      @left = left
      @operator = operator
      @right = right
    end

    def accept(visitor)
      visitor.visit_binary
    end

    def to_s
      " #{left.to_s} #{operator&.type} #{right.to_s} "
    end
  end

  class Grouping
    attr_reader :expression

    def initialize(expression)
      @expression = expression
    end

    def accept(visitor)
      visitor.visit_grouping
    end

    def to_s
      " #{expression.to_s} "
    end
  end

  class Literal
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def accept(visitor)
      visitor.visit_literal
    end

    def to_s
      " #{value} "
    end
  end

  class Unary
    attr_reader :operator, :right

    def initialize(operator, right)
      @operator = operator
      @right = right
    end

    def accept(visitor)
      visitor.visit_unary
    end

    def to_s
      " #{operator&.type} #{right.to_s} "
    end
  end

end