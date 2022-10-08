# Generated file with all AST expressions type

class Expression
  class Assign
    attr_reader :name, :value

    def initialize(name, value)
      @name = name
      @value = value
    end

    def accept(visitor)
      visitor.visit_assign(self)
    end
  end

  class Binary
    attr_reader :left, :operator, :right

    def initialize(left, operator, right)
      @left = left
      @operator = operator
      @right = right
    end

    def accept(visitor)
      visitor.visit_binary(self)
    end
  end

  class Grouping
    attr_reader :expression

    def initialize(expression)
      @expression = expression
    end

    def accept(visitor)
      visitor.visit_grouping(self)
    end
  end

  class Literal
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def accept(visitor)
      visitor.visit_literal(self)
    end
  end

  class Logical
    attr_reader :left, :operator, :right

    def initialize(left, operator, right)
      @left = left
      @operator = operator
      @right = right
    end

    def accept(visitor)
      visitor.visit_logical(self)
    end
  end

  class Unary
    attr_reader :operator, :right

    def initialize(operator, right)
      @operator = operator
      @right = right
    end

    def accept(visitor)
      visitor.visit_unary(self)
    end
  end

  class Variable
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def accept(visitor)
      visitor.visit_variable(self)
    end
  end

end