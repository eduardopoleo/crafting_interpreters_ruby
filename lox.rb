require "readline"

def run(source)
  puts source
end

def run_file(file)
  # breaks the files into charts and processed them
  # TODO
  file_data = File.open(file).read
  run(file_data)
end

def run_prompt(command)
  # reads the line
  run()
end

if ARGV.length > 1
  puts "Usage: lox [script]"
elsif ARGV.length == 1
  run_file(ARGV[0])
else
  while buf = Readline.readline("> ", true)
    run(buf)    
  end
end