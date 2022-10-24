require_relative './token'
require_relative './scanner'
require_relative './lexer_modes/main_lexer_mode'
require_relative './lexer_modes/string_interpolation_lexer_mode'
require_relative './lexer_modes/string_lexer_mode'

class ModalLexer
  attr_reader :tokens, :scanner, :mode_stack

  def initialize(source)
    @scanner = Scanner.new(source)
    @tokens = []
    @mode_stack = [MainLexerMode]
  end

  def scan
    while !scanner.at_end?
      scanner.start
      mode = mode_stack.last
      token = mode.next_token(scanner, mode_stack)
      tokens << token if token 
    end

    tokens << Token.new(Token::Type::EOF, "", nil, scanner.current_line)
  end
end

