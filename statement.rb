# Generated file with all AST expressions type

class Statement
  class Block
    attr_reader :statements

    def initialize(statements)
      @statements = statements
    end

    def accept(visitor)
      visitor.visit_block(self)
    end
  end

  class Expression
    attr_reader :expression

    def initialize(expression)
      @expression = expression
    end

    def accept(visitor)
      visitor.visit_expression(self)
    end
  end

  class If
    attr_reader :condition, :then_branch, :else_branch

    def initialize(condition, then_branch, else_branch)
      @condition = condition
      @then_branch = then_branch
      @else_branch = else_branch
    end

    def accept(visitor)
      visitor.visit_if(self)
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