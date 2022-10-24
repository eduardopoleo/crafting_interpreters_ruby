class MainLexerMode
  attr_reader :scanner, :mode_stack

  def self.next_token(scanner, mode_stack)
    new(scanner, mode_stack).next_token
  end
  
  def initialize(scanner, mode_stack)
    @scanner = scanner
    @mode_stack = mode_stack
  end

  def next_token
    type = nil
    literal = nil

    case scanner.char_at_start
    when '('
      type = Token::Type::LEFT_PAREN
    when ')'
      type = Token::Type::RIGHT_PAREN
    when '{'
      type = Token::Type::LEFT_BRACE
    when '}'
      type = Token::Type::RIGHT_BRACE
    when '['
      type = Token::Type::LEFT_SQUARE
    when ']'
      type = Token::Type::RIGHT_SQUARE
    when ','
      type = Token::Type::COMMA
    when '.'
      type = Token::Type::DOT
    when '-'
      type = Token::Type::MINUS
    when '+'
      type = Token::Type::PLUS
    when ';'
      type = Token::Type::SEMICOLON
    when '*'
      type = Token::Type::STAR
    when '%'
      type = Token::Type::MODULO
    when '!'
      # these are a bit more complicated because we need to look ahead 1 space 
      # to where the pointer is to decide what kid of token it should be
      type = if scanner.token_end_matches?('=')
        # We need to consume the current pointer '=' because we've confirmed
        # that is part of the token we're currently scanning
        scanner.advance_token_end
        type = Token::Type::BANG_EQUAL
      else
        type = Token::Type::BANG
      end

    when '='
      type = if scanner.token_end_matches?('=')
        scanner.advance_token_end
        type = Token::Type::EQUAL_EQUAL
      else
        type = Token::Type::EQUAL
      end
    when '<'
      type = if scanner.token_end_matches?('=')
        scanner.advance_token_end
        type = Token::Type::LESS_EQUAL
      else
        type = Token::Type::LESS
      end
    when '>'
      type = if scanner.token_end_matches?('=')
        scanner.advance_token_end
        type = Token::Type::GREATER_EQUAL
      else
        type = Token::Type::GREATER
      end
    when '/'
      # Means that pointer is also / which means we're starting a comment
      # this a more complex look ahead cuz we have to exhaust the whole line
      if scanner.token_end_matches?('/')
        # advance the pointer once more because we need to account for the second /
        scanner.advance_token_end
        while(scanner.peek != "\n" && !scanner.at_end?) do
          # advance until the end of the line until the comment is done
          scanner.advance_token_end
        end
      # means that's a long format comment
      elsif scanner.token_end_matches?('*')
        scanner.advance_token_end
        loop do
          # we need to look ahead twice to know if we've encountered the
          # end of the long format comment
          if (scanner.peek == "*" && scanner.peek_next == "/") || scanner.at_end?
            # we've confirmed that this is the end of the comment
            # and we need to exhaust the */
            2.times { scanner.advance_token_end } 
            break
          end
          scanner.advance_line if scanner.peek == "\n"
          scanner.advance_token_end # advance until is done
        end
      else
        type = add_token(Token::Type::SLASH)
      end
    when ' '
    when "\r"
    when "\t"
    when "\n"
      scanner.advance_line
    when '"'
      # change this to store the strings
      type = Token::Type::STRING_START
      mode_stack << StringLexerMode
    else
      # These are now "free form" type of expression so we can't programatically
      # consume pointer cuz we do not know how long characters will be.
      if digit?(scanner.char_at_start)
        type = Token::Type::NUMBER
        literal = calculate_number
      elsif alpha?(scanner.char_at_start)
        type, literal = calculate_identifier
      else
        raise "Character not recognized #{scanner.char_at_start} line #{scanner.current_line}"
      end
    end

    Token.new(
      type,
      scanner.current_lexeme,
      literal,
      scanner.current_line
    ) if type
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

  def calculate_identifier
    while(alpha_numeric?(scanner.peek)) do
      scanner.advance_token_end
    end

    text = scanner.current_lexeme
    type = Token::Type::KEYWORDS[text]
    type = Token::Type::IDENTIFIER if type.nil?

    [type, text]
  end
  
  def calculate_number
    while(digit?(scanner.peek)) do
      scanner.advance_token_end
    end

    if scanner.peek == '.' && digit?(scanner.peek_next)
      scanner.advance_token_end
      while(digit?(scanner.peek)) do
        scanner.advance_token_end
      end
    end

    scanner.current_lexeme.to_f
  end
end