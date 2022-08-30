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
    else
      # TODO get this to work with a top level error handler that
      # prints out the line etc
      raise "Character not recognized #{prev_char}"
    end
  end

  def peek
    return '\0' if at_end?
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
    text = source[start...current]
    tokens << Token.new(type, text, literal, line)
  end
end
