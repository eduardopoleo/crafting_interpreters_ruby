class Token
  attr_reader :type, :lexeme, :literal, :line

  def initialize(type, lexeme, literal, line)
    @type = type
    @lexeme = lexeme
    @literal = literal
    @line = line
  end

  def to_s
    "type: #{type}, lexeme: #{lexeme}, literal:  #{literal}"
  end

  class Type
    # TODO; Changed all this by 'LEFT_PAREN' etc and the references
    LEFT_PAREN = '('
    RIGHT_PAREN = ')'
    LEFT_BRACE = '{'
    RIGHT_BRACE = '}'
    COMMA = ','
    DOT = '.'
    MINUS = '-'
    PLUS = '+'
    SEMICOLON = ';'
    SLASH ='/'
    STAR = '*'
    MODULO = '%'
    EOF = 'EOF'
  
    #  One or two character tokens.
    BANG = '!'
    BANG_EQUAL = '!='
    EQUAL = '='
    EQUAL_EQUAL = '=='
    GREATER = '>'
    GREATER_EQUAL = '>='
    LESS = '<'
    LESS_EQUAL = '<='
  
    # Literals.
    IDENTIFIER = 'IDENTIFIER'
    STRING = 'STRING'
    NUMBER = 'NUMBER'
    
    # need
    KEYWORDS = {
      "and"    => 'AND',
      "class"  => 'CLASS',
      "else"   => 'ELSE',
      "false"  => 'FALSE',
      "for"    => 'FOR',
      "fun"    => 'FUN',
      "if"     => 'IF',
      'elif'   => 'ELIF',
      "nil"    => 'NIL',
      "or"     => 'OR',
      "print"  => 'PRINT',
      "return" => 'RETURN',
      "super"  => 'SUPER',
      "this"   => 'THIS',
      "true"   => 'TRUE',
      "var"    => 'VAR',
      "while"  => 'WHILE'
    }
  end
end