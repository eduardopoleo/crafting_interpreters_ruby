class Scanner
  attr_accessor :source, :token_start, :token_end, :current_line

  def initialize(source)
    @source = source
    @token_start = 0
    @token_end = 0
    @current_line = 1
  end

  def start
    @token_start = token_end
    advance_token_end
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
