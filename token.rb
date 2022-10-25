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
    LEFT_SQUARE  = '['
    RIGHT_SQUARE = ']'
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
    
    # String related
    STRING_START = 'STRING_START'
    STRING_END = 'STRING_END'
    STRING_INT_START = 'STRING_INT_START'
    STRING_INT_END = 'STRING_INT_END'
    STRING_LIT = 'STRING_LIT'

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
      "while"  => 'WHILE',
      "break"  => 'BREAK'
    }
  end
end