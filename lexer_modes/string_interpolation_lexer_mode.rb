require_relative './main_lexer_mode'

class StringInterpolationLexerMode
  attr_reader :scanner, :mode_stack, :delegate

  def self.next_token(scanner, mode_stack)
    new(scanner, mode_stack).next_token
  end
  
  def initialize(scanner, mode_stack)
    @scanner = scanner
    @mode_stack = mode_stack
    @delegate = MainLexerMode.new(scanner, mode_stack)
  end

  def next_token
    return delegate.next_token unless scanner.char_at_start == '}'

    mode_stack.pop

    Token.new(
      Token::Type::STRING_INT_END,
      scanner.current_lexeme,
      nil,
      scanner.current_line
    )
  end
end
