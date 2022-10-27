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

  class Function
    attr_reader :name, :params, :body

    def initialize(name, params, body)
      @name = name
      @params = params
      @body = body
    end

    def accept(visitor)
      visitor.visit_function(self)
    end
  end

  class If
    attr_reader :condition, :then_branch, :elif_statements, :other_branch

    def initialize(condition, then_branch, elif_statements, other_branch)
      @condition = condition
      @then_branch = then_branch
      @elif_statements = elif_statements
      @other_branch = other_branch
    end

    def accept(visitor)
      visitor.visit_if(self)
    end
  end

  class Elif
    attr_reader :condition, :branch

    def initialize(condition, branch)
      @condition = condition
      @branch = branch
    end

    def accept(visitor)
      visitor.visit_elif(self)
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

  class Return
    attr_reader :keyword, :value

    def initialize(keyword, value)
      @keyword = keyword
      @value = value
    end

    def accept(visitor)
      visitor.visit_return(self)
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

  class While
    attr_reader :condition, :body

    def initialize(condition, body)
      @condition = condition
      @body = body
    end

    def accept(visitor)
      visitor.visit_while(self)
    end
  end

  class Break
    attr_reader 

    def initialize()
    end

    def accept(visitor)
      visitor.visit_break(self)
    end
  end

  class Class
    attr_reader :name, methods

    def initialize(name, methods)
      @name, methods = name, methods
    end

    def accept(visitor)
      visitor.visit_class(self)
    end
  end

end