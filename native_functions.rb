require_relative './lox_callable'
require "readline"

module NativeFunctions
  def clock
    Class.new(LoxCallable) do
      def arity; 0; end
      def call(_interpreter, _arguments)
        Time.now
      end
      def to_s; "<native fn>"; end
    end.new
  end

  def readline
    Class.new(LoxCallable) do
      def arity; 1; end
      def call(_interpreter, arguments)
        # message is the only argument
        Readline.readline("#{arguments[0]}", true)
      end
      def to_s; "<native fn>"; end
    end.new
  end

  def coerce_to_i
    Class.new(LoxCallable) do
      def arity; 1; end
      def call(_interpreter, arguments)
        arguments[0].to_i
      end
      def to_s; "<native fn>"; end
    end.new
  end
end
