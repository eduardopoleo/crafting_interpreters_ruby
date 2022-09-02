# If you're on the interpreter file just call this with
# ruby ./ and the file will be generated 
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
    # TODO move all this nonsese into a template
    File.open(path, 'w') do |f|
      write("# Auto generated. Contains AST definition\n", f)
      write("\n", f)
      write("class #{base_name.capitalize}\n", f)
      write("\n", f)
      increase_indent
      types.each do |type, fields|
        write("class #{type.capitalize}", f)
        write("\n", f)
        increase_indent
        write(generate_reader_attributes(fields), f)
        write("\n", f)
        write("\n", f)
        write("def initialize(#{generate_field_list(fields)})", f)
        write("\n", f)
        increase_indent
        fields.each do |field|
          write("@#{field} = #{field}", f)
          write("\n", f)
        end
        decrease_indent
        write("end", f)
        write("\n", f)
        decrease_indent
        write("end", f)
        write("\n", f)
        write("\n", f)
      end
      decrease_indent
      write('end', f)
    end
  end

  def write(text, f)
    f.write("#{apply_indent}#{text}")
  end
  
  def generate_field_list(fields)
    fields.map { |field| "#{field}" }.join(', ')
  end

  def generate_reader_attributes(fields)
    "attr_reader " +
    fields.map { |field| ":#{field}" }.join(', ')
  end

  def increase_indent
    @indent += 1
  end

  def decrease_indent
    @indent -= 1
  end

  def apply_indent
    "  " * indent
  end
end

AstGenerator.generate(ARGV[0])