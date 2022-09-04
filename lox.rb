require "readline"
require_relative './scanner'
require_relative './parser'

class Lox
  attr_reader :source, :had_error

  def initialize(source = [])
    @source = source
    @had_error = false
  end

  def self.main(source)
    new(source).main
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

  private

  def run(source)
    tokens = Scanner.new(source).scan
    expression = Parser.parse(tokens)

    puts expression.to_s
  end

  def run_file(file)
    run(File.open(file).read)
    exit(65) if @had_error
  end
  
  def run_prompt(command)
    run(command)
    @had_error = false
  end

  def display_error(line, location, message)
    "[line #{line}] Error #{location}: #{message}"
  end
end

Lox.main(ARGV)


