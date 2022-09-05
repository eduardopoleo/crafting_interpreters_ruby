class PrintVisitor
  def self.visit_binary(exp)
    # Why do we need safe navigation here?
    "#{exp.left&.accept(self)} #{exp.operator&.type} #{exp.right&.accept(self)}"
  end

  def self.visit_grouping(exp)
    "#{exp.expression.accept(self)}"
  end

  def self.visit_literal(exp)
    "#{exp.value}"
  end

  def self.visit_unary(exp)
    "#{exp.operator.type} #{exp.right.accept(self)}"
  end
end