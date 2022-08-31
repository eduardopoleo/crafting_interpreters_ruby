require_relative './token_type'
require_relative './token'

class Scanner
  attr_reader :source, :tokens, :start, :current, :line

  def initialize(source)
    @source = source
    @tokens = []
    @start = 0
    @current = 0
    @line = 1
  end

  def scan_tokens
    while !at_end? do
      @start = current
      scan_token
    end

    tokens << Token.new(TokenType::EOF, "", nil, line)
  end

  private

  def scan_token
    advance

    case source[start]
    when '('
       add_token('LEFT_PAREN')
    when ')'
       add_token('RIGHT_PAREN')
    when '{'
       add_token('LEFT_BRACE')
    when '}'
       add_token('RIGHT_BRACE')
    when ','
       add_token('COMMA')
    when '.'
       add_token('DOT')
    when '-'
       add_token('MINUS')
    when '+'
       add_token('PLUS')
    when ';'
       add_token('SEMICOLON')
    when '*'
       add_token('STAR');
    when '!'
      add_token(current_matches?('=') ? 'BANG_EQUAL' : 'BANG')
    when '='
      add_token(current_matches?('=') ? 'EQUAL_EQUAL' : 'EQUAL')
    when '<'
      add_token(current_matches?('=') ? 'LESS_EQUAL' : 'LESS')
    when '>'
      add_token(current_matches?('=') ? 'GREATER_EQUAL' : 'GREATER')
    when '/'
      if current_matches?('/') # means that is a comment
        while(peek != "\n" && !at_end?) do
          advance # advance until is done
        end
      else
        add_token('SLASH')
      end
    when ' '
    when "\r"
    when "\t"
    when "\n"
      @line += 1
    when '"'
      store_string
    else
      if digit?(source[start])
        store_number
      elsif alpha?(source[start])
        store_identifier
      else
        # TODO get this to work with a top level error handler that
        # prints out the line etc
        raise "Character not recognized #{source[start]}"
      end
    end
  end

  def digit?(c)
    c.to_s =~ /[0-9]/
  end

  def alpha?(c)
    (c >= 'a' && c < 'z') || (c >= 'A' && c <= 'Z') || c == '_'
  end

  def alpha_numeric?(c)
    alpha?(c) || digit?(c)
  end

  def store_identifier
    while(alpha_numeric?(peek)) do
      advance
    end

    text = source[start...current]
    type = TokenType::KEYWORDS[text]
    type = TokenType::IDENTIFIER if type.nil?
    add_token(type)
  end
  
  def store_number
    while(digit?(peek)) do
      advance
    end

    if peek == '.' && digit?(peek_next)
      advance
      while(digit?(peek)) do
        advance
      end
    end

    # The literal number value is taken from start and current
    # because it does not have to account for the ""
    literal_value = source[start...current].to_f
    add_token('NUMBER', literal_value)
  end

  def store_string
    while(peek != '"' && !at_end?) do
      advance
    end

    raise "Unfinished string" if at_end?
    
    # the current is " advancing makes it so that the lexeme includes "
    # cuz the end piece is non inclusive
    advance

    # the literal value should not include the "
    # start + 1 gets rid of the "
    # current - 1 places it back on the end " but because is not inclusive it only
    # captures the literal
    literal_value = source[start+1...current-1]
    add_token('STRING', literal_value)
  end

  def peek_next
    return "\0" if current + 1 >= source.length
    return source[current + 1]
  end

  def peek
    return "\0" if at_end?
    return source[current]
  end

  def current_matches?(expected_current_char)
    return false if at_end?
    return false if source[current] != expected_current_char

    @current += 1
    true
  end

  def at_end?
    return current >= source.length
  end

  def advance
    @current += 1
  end

  def add_token(type, literal=nil)
    lexeme = source[start...current] # the full lexeme as it was parsed from the algo
    # literal is the actua value that matters
    tokens << Token.new(type, lexeme, literal, line)
  end
end
