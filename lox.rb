require "readline"
require_relative './scanner'
require_relative './parser'
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
    tokens = Scanner.new(source).scan
    expression = Parser.parse(tokens)
    puts expression.accept(AstPrinter)
    interpreter = Interpreter.interpret(expression)
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


