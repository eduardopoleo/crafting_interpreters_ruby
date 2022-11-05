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

  class Call
    attr_reader :callee, :paren, :arguments

    def initialize(callee, paren, arguments)
      @callee = callee
      @paren = paren
      @arguments = arguments
    end

    def accept(visitor)
      visitor.visit_call(self)
    end
  end

  class Get
    attr_reader :object, :name

    def initialize(object, name)
      @object = object
      @name = name
    end

    def accept(visitor)
      visitor.visit_get(self)
    end
  end

  class Set
    attr_reader :object, :name, :value

    def initialize(object, name, value)
      @object = object
      @name = name
      @value = value
    end

    def accept(visitor)
      visitor.visit_set(self)
    end
  end

  class Super
    attr_reader :keyword, :method

    def initialize(keyword, method)
      @keyword = keyword
      @method = method
    end

    def accept(visitor)
      visitor.visit_super(self)
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

  class This
    attr_reader :keyword

    def initialize(keyword)
      @keyword = keyword
    end

    def accept(visitor)
      visitor.visit_this(self)
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

  class Array
    attr_reader :elements

    def initialize(elements)
      @elements = elements
    end

    def accept(visitor)
      visitor.visit_array(self)
    end
  end

  class ArrayAccessor
    attr_reader :array, :index, :value_exp, :operation

    def initialize(array, index, value_exp, operation)
      @array = array
      @index = index
      @value_exp = value_exp
      @operation = operation
    end

    def accept(visitor)
      visitor.visit_array_accessor(self)
    end
  end

  class StringGroup
    attr_reader :expressions

    def initialize(expressions)
      @expressions = expressions
    end

    def accept(visitor)
      visitor.visit_string_group(self)
    end
  end

end