# If you're on the interpreter file just call this with
# ruby ./ and the file will be generated 
require 'erb'
require_relative './expressions_template'

class AstGenerator
  attr_reader :output_dir, :indent

  def self.generate(output_dir)
    new(output_dir).generate
  end

  def initialize(output_dir)
    @output_dir = output_dir
    @indent = 0
  end

  AST_ATTRIBUTES = {
    'binary'   => ['left', 'operator', 'right'],
    'grouping' => ['expression'],
    'literal'  => ['value'],
    'unary'    => ['operator', 'right']
  }

  def generate
    define_ast('expression', AST_ATTRIBUTES)
  end

  private

  def define_ast(base_name, types)
    path = "#{output_dir}/#{base_name}.rb"
    template = ERB.new(EXPRESSIONS_TEMPLATE, nil, '-')
    File.open(path, 'w') { |f| f.write(template.result(binding)) }
  end
end

AstGenerator.generate(ARGV[0])