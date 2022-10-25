# If you're on the interpreter file just call this with
# ruby tool/ast_generator.rb ./ and the file will be generated 
require 'erb'

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
    'assign'      => ['name', 'value'],
    'binary'      => ['left', 'operator', 'right'],
    'call'        => ['callee', 'paren', 'arguments'],
    'grouping'    => ['expression'],
    'literal'     => ['value'],
    'logical'     => ['left', 'operator', 'right'],
    'unary'       => ['operator', 'right'],
    'variable'    => ['name'],
    'array'       => ['elements'],
    'array_accessor' => ['array', 'index', 'value_exp', 'operation'],
    'string_group' => ['expressions']
  }

  AST_STATEMENTS = {
    'block'      => ['statements'],
    'expression' => ['expression'],
    'function'   => ['name', 'params', 'body'],
    'if'         => ['condition', 'then_branch', 'elif_statements', 'other_branch'],
    'elif'       => ['condition', 'branch'],
    'print'      => ['expression'],
    'return'     => ['keyword', 'value'],
    'var'        => ['name', 'initializer'],
    'while'      => ['condition', 'body'],
    'break'      => []
  }

  def generate
    define_ast('expression', AST_ATTRIBUTES)
    define_ast('statement', AST_STATEMENTS)
  end

  private

  def define_ast(base_name, types)
    path = "#{output_dir}/#{base_name}.rb"
    template = ERB.new(File.read(__dir__  + '/expressions_template.rb'), nil, '-')
    File.open(path, 'w') { |f| f.write(template.result(binding)) }
  end
end

AstGenerator.generate(ARGV[0])