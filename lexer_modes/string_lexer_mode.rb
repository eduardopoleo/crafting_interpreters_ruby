class StringLexerMode
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
    if scanner.char_at_start == '%' and scanner.char_at_end == "{"
      scanner.advance_token_end
      type = Token::Type::STRING_INT_START
      mode_stack << StringInterpolationLexerMode
    elsif scanner.char_at_start == '"'
      type = Token::Type::STRING_END
      mode_stack.pop
    elsif scanner.char_at_start == '%'
      type = Token::Type::STRING_LIT
      literal = scanner.current_lexeme
    else
      type = Token::Type::STRING_LIT 
      while scanner.char_at_end != '"' && scanner.char_at_end != '%'
        scanner.advance_token_end
      end
      type = Token::Type::STRING_LIT
      literal = scanner.current_lexeme
    end

    Token.new(
      type,
      scanner.current_lexeme,
      literal,
      scanner.current_line
    )
  end
end