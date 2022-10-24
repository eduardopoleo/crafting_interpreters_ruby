require_relative './token'


# "hello %{expression} something else"
# string_init
# string_literal, 'hello'
# string_inter_pol
# expression
# string_literal 'something else'
class Scanner
  attr_accessor :source, :token_start, :token_end, :current_line

  def initialize(source)
    @source = source
    @token_start = 0
    @token_end = 0
    @current_line = 1
  end

  def peek_next
    return "\0" if token_end + 1 >= source.length
    return source[token_end + 1]
  end

  def peek
    return "\0" if at_end?
    return source[token_end]
  end

  def char_at_start
    return source[token_start]
  end

  def char_at_end
    return source[token_end]
  end

  def token_end_matches?(expected_pointer_char)
    return false if at_end?
    return false if source[token_end] != expected_pointer_char

    true
  end

  def current_lexeme
    source[token_start...token_end]
  end

  def at_end?
    return token_end >= source.length
  end

  def advance_token_end
    @token_end += 1
  end

  def advance_line
    @current_line += 1
  end
end

class ModalLexer
  attr_reader :mode, :tokens, :scanner

  def initialize(source)
    @scanner = Scanner.new(source)
    @tokens = []
    @mode_stack = [MainLexerMode]
  end

  def scan
    while !scanner.at_end?
      token = next_token
      tokens << token if token 
    end

    tokens << Token.new(Token::Type::EOF, "", nil, scanner.current_line)
  end

  def next_token
     # Beginning of the token is where the previous token finished
    scanner.token_start = scanner.token_end
     # Move the end of the token 1 step further
    scanner.advance_token_end
    @mode_stack.last.next_token(scanner)
  end
end

class MainLexerMode
  attr_reader :scanner

  def self.next_token(scanner)
    new(scanner).next_token
  end
  
  def initialize(scanner)
    @scanner = scanner
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
      store_string
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

  # def store_string
  #   while(peek != '"' && !at_end?) do
  #     scanner.advance_token_end
  #   end

  #   raise "Unfinished string" if at_end?
    
  #   # advancing here makes sure we consume the pointer with the ending "
  #   scanner.advance_token_end

  #   # for a scan with "my_string"
  #   # lexeme would be "my_string" ->  start...pointer
  #   # literal: my_string -> (start + 1)...(pointer - 1) to removes the ""
  #   literal_value = source[start+1...pointer-1]
  #   add_token(Token::Type::STRING, literal_value)
  # end
end
