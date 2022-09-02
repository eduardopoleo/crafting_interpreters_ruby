# Auto generated. Contains AST definition

class Expression

  class Binary  
    attr_reader :left, :operator, :right    
    
    def initialize(left, operator, right)    
      @left = left      
      @operator = operator      
      @right = right      
    end    
  end  
  
  class Grouping  
    attr_reader :expression    
    
    def initialize(expression)    
      @expression = expression      
    end    
  end  
  
  class Literal  
    attr_reader :value    
    
    def initialize(value)    
      @value = value      
    end    
  end  
  
  class Unary  
    attr_reader :operator, :right    
    
    def initialize(operator, right)    
      @operator = operator      
      @right = right      
    end    
  end  
  
end