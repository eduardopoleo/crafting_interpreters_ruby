require "readline"
require_relative './modal_lexer'
require_relative './parser'
require_relative './resolver'
require_relative './interpreter'
require_relative './ast_printer'

class Lox
  attr_reader :source, :had_error

  def initialize(source = [])
    @source = source
    @had_error = false
  end

  def self.main(source)
    new(source).main
  end

  def self.display_error(line, location, message)
    puts "[line #{line}] Error #{location}: #{message}"
  end

  def main
    if source.length > 1
      puts "Usage: lox [script]"
    elsif source.length == 1
      run_file(ARGV[0])
    else
      while buf = Readline.readline("> ", true)
        run(buf)    
      end
    end
  end

  def run(source)
    tokens = ModalLexer.new(source).scan
    require 'pry'; binding.pry
    # statements = Parser.parse(tokens)
    # interpreter = Interpreter.new
    # Stores the result on the interpreter's locals
    # Resolver.new(interpreter).resolve_multiple(statements)
    # interpreter.interpret(statements)
  end

  def run_file(file)
    run(File.open(file).read)
    exit(65) if @had_error
  end
  
  def run_prompt(command)
    run(command)
    @had_error = false
  end
end

Lox.main(ARGV)


