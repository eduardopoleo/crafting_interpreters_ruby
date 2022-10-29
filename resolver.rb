class Resolver
  attr_reader :interpreter, :scopes

  def initialize(interpreter)
    @interpreter = interpreter
    @scopes = []
  end

  def resolve_multiple(stms_or_exps)
    stms_or_exps.each do |stm_or_exp|
      resolve(stm_or_exp)
    end
  end

  def resolve(stm_or_exp)
    stm_or_exp.accept(self)
  end

  def visit_block(block)
    wrap_scope do
      resolve_multiple(block.statements)
    end
    return nil
  end

  def visit_var(var)
    declare(var.name)
    if var.initializer != nil
      resolve(var.initializer)
    end

    define(var.name)
    return nil
  end

  def visit_variable(var_exp)
    # It's not trivial to see but this means that you have something like var a = a;
    # - var gets resolved on visit_var
    # - inside the above loop a gets resolved in here
    # - cuz scopes[-1][var_exp.name.lexeme] == false we know that define has not been called
    if !scopes.empty? && scopes[-1][var_exp.name.lexeme] == false
      raise "Can't read local variable in its own initializer"
    end

    resolve_local(var_exp, var_exp.name)
    return nil
  end

  def visit_assign(exp)
    resolve(exp.value)
    resolve_local(exp, exp.name)
    return nil
  end

  def visit_function(function)
    declare(function.name)
    define(function.name)

    resolve_function(function)
    return nil
  end

  def visit_expression(expression_statement)
    resolve(expression_statement.expression)
    return nil
  end

  def visit_if(if_statement)
    resolve(if_statement.condition)
    resolve(if_statement.then_branch)
    if_statement.elif_statements.each do |stm| resolve(stm)
      resolve(stm.condition)
      resolve(stm.branch)
    end
    resolve(if_statement.other_branch) if !if_statement.other_branch.nil?
    return nil
  end
    
  def visit_print(print_statement)
    resolve(print_statement.expression)
    return nil
  end

  def visit_return(return_statement)
    if return_statement.value != nil
      resolve(return_statement.value)
    end

    return nil
  end

  def visit_while(while_statement)
    resolve(while_statement.condition)
    resolve(while_statement.body)
    return nil
  end

  def visit_binary(binary)
    resolve(binary.left)
    resolve(binary.right)
    return nil
  end

  def visit_call(call)
    resolve(call.callee)

    call.arguments.each do |arg|
      resolve(arg)
    end

    return nil
  end

  def visit_grouping(grouping)
    resolve(grouping.expression)
    return nil
  end

  def visit_literal(literal)
    return nil
  end

  def visit_logical(logical)
    resolve(logical.left)
    resolve(logical.right)
    return nil
  end

  def visit_unary(unary)
    resolve(unary.right)
    return nil
  end

  def visit_array(array)
    array.elements.each do |element|
      resolve(element)
    end
    return nil
  end

  def visit_array_accessor(array_accessor)
    resolve(array_accessor.array)
    resolve(array_accessor.index)

    if array_accessor.operation == 'set'
      resolve(array_accessor.value_exp)
    end
    nil
  end

  def visit_string_group(string_group)
    string_group.expressions.each do |exp|
      resolve(exp)
    end
    nil
  end

  def visit_break(_break); end # noop

  def visit_class(klass)
    declare(klass.name)
    define(klass.name)

    klass.methods.each do |method|
      resolve_function(method)
    end
    nil
  end

  def visit_get(get_exp)
    resolve(get_exp.object)
    nil
  end

  def visit_set(set_exp)
    resolve(set_exp.value)
    resolve(set_exp.object)
    nil
  end

  private

  def declare(name)
    return if scopes.empty?
    scope = scopes[-1]

    if scope.has_key?(name.lexeme)
      raise "Already a var in the scope with this name"
    end

    scope[name.lexeme] = false    
  end

  def define(name)
    return if scopes.empty?
    scopes[-1][name.lexeme] = true
  end

  def wrap_scope
    scopes << {}
    yield
    scopes.pop
  end

  def resolve_local(exp, name)
    (scopes.size - 1).downto(0) do |i|
      if scopes[i].has_key?(name.lexeme)
        interpreter.resolve(exp, scopes.size - 1 - i)
      end
    end
  end

  def resolve_function(function)
    wrap_scope do
      function.params.each do |param|
        declare(param)
        define(param)
      end
      resolve_multiple(function.body)
    end
  end
end