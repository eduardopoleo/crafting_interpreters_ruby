require_relative './token'

class Scanner
  attr_reader :source, :tokens, :start, :pointer, :line

  def initialize(source)
    @source = source
    @tokens = []
    @start = 0
    @pointer = 0
    @line = 1
  end

  def scan
    while !at_end? do
      # Each loop here scans only 1 token. Once token is found 
      # we move start to pointer (which is where the next token possibly starts)
      # and search for the next token again
      @start = pointer
      # Pointer is always 1 ahead of start to be able to look ahead easier
      advance_pointer
      scan_next_token
    end

    tokens << Token.new(Token::Type::EOF, "", nil, line)
  end

  def scan_next_token
    case source[start]
    # These lexemes are easy becuase they consists of only 1 character
    when '('
       add_token(Token::Type::LEFT_PAREN)
    when ')'
       add_token(Token::Type::RIGHT_PAREN)
    when '{'
       add_token(Token::Type::LEFT_BRACE)
    when '}'
       add_token(Token::Type::RIGHT_BRACE)
    when ','
       add_token(Token::Type::COMMA)
    when '.'
       add_token(Token::Type::DOT)
    when '-'
       add_token(Token::Type::MINUS)
    when '+'
       add_token(Token::Type::PLUS)
    when ';'
       add_token(Token::Type::SEMICOLON)
    when '*'
       add_token(Token::Type::STAR);
    when '%'
       add_token(Token::Type::MODULO);
    when '!'
      # these are a bit more complicated because we need to look ahead 1 space 
      # to where the pointer is to decide what kid of token it should be
      token = if pointer_matches?('=')
        # We need to consume the current pointer '=' because we've confirmed
        # that is part of the token we're currently scanning
        advance_pointer
        Token::Type::BANG_EQUAL
      else
        Token::Type::BANG
      end

      add_token(token)
    when '='
      token = if pointer_matches?('=')
        advance_pointer
        Token::Type::EQUAL_EQUAL
      else
        Token::Type::EQUAL
      end

      add_token(token)
    when '<'
      token = if pointer_matches?('=')
        advance_pointer
        Token::Type::LESS_EQUAL
      else
        Token::Type::LESS
      end

      add_token(token)
    when '>'
      token = if pointer_matches?('=')
        advance_pointer
        Token::Type::GREATER_EQUAL
      else
        Token::Type::GREATER
      end

      add_token(token)
    when '/'
      # Means that pointer is also / which means we're starting a comment
      # this a more complex look ahead cuz we have to exhaust the whole line
      if pointer_matches?('/')
        # advance the pointer once more because we need to account for the second /
        advance_pointer
        while(peek != "\n" && !at_end?) do
          # advance until the end of the line until the comment is done
          advance_pointer
        end
      # means that's a long format comment
      elsif pointer_matches?('*')
        advance_pointer
        loop do
          # we need to look ahead twice to know if we've encountered the
          # end of the long format comment
          if (peek == "*" && peek_next == "/") || at_end?
            # we've confirmed that this is the end of the comment
            # and we need to exhaust the */
            2.times { advance_pointer } 
            break
          end
          @line += 1 if peek == "\n"
          advance_pointer # advance until is done
        end
      else
        add_token(Token::Type::SLASH)
      end
    when ' '
    when "\r"
    when "\t"
    when "\n"
      @line += 1
    when '"'
      store_string
    else
      # These are now "free form" type of expression so we can't programatically
      # consume pointer cuz we do not know how long characters will be.
      if digit?(source[start])
        store_number
      elsif alpha?(source[start])
        store_identifier
      else
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
      advance_pointer
    end

    text = source[start...pointer]
    type = Token::Type::KEYWORDS[text]
    type = Token::Type::IDENTIFIER if type.nil?
    add_token(type)
  end
  
  def store_number
    while(digit?(peek)) do
      advance_pointer
    end

    if peek == '.' && digit?(peek_next)
      advance_pointer
      while(digit?(peek)) do
        advance_pointer
      end
    end

    # The literal number value is taken from start and current
    # because it does not have to account for the ""
    literal_value = source[start...pointer].to_f
    add_token(Token::Type::NUMBER, literal_value)
  end

  def store_string
    while(peek != '"' && !at_end?) do
      advance_pointer
    end

    raise "Unfinished string" if at_end?
    
    # advancing here makes sure we consume the pointer with the ending "
    advance_pointer

    # for a scan with "my_string"
    # lexeme would be "my_string" ->  start...pointer
    # literal: my_string -> (start + 1)...(pointer - 1) to removes the ""
    literal_value = source[start+1...pointer-1]
    add_token(Token::Type::STRING, literal_value)
  end

  def peek_next
    return "\0" if pointer + 1 >= source.length
    return source[pointer + 1]
  end

  def peek
    return "\0" if at_end?
    return source[pointer]
  end

  def pointer_matches?(expected_pointer_char)
    return false if at_end?
    return false if source[pointer] != expected_pointer_char

    true
  end

  def at_end?
    return pointer >= source.length
  end

  def advance_pointer
    @pointer += 1
  end

  def add_token(type, literal=nil)
    # takes everything from the start of the token to where current is non inclusicve
    lexeme = source[start...pointer] # the full lexeme as it was parsed from the algo
    # literal is the actua value that matters
    tokens << Token.new(type, lexeme, literal, line)
  end
end
