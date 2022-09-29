# Generated file with all AST expressions type

class Statement
  class Expression
    attr_reader :expression

    def initialize(expression)
      @expression = expression
    end

    def accept(visitor)
      visitor.visit_expression(self)
    end
  end

  class Print
    attr_reader :expression

    def initialize(expression)
      @expression = expression
    end

    def accept(visitor)
      visitor.visit_print(self)
    end
  end

  class Var
    attr_reader :name, :initializer

    def initialize(name, initializer)
      @name = name
      @initializer = initializer
    end

    def accept(visitor)
      visitor.visit_var(self)
    end
  end

end