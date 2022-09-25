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

end