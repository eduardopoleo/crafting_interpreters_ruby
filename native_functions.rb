require_relative './lox_callable'

module NativeFunctions
  def clock
    Class.new(LoxCallable) do
      def arity; 0; end
      def call(_interpreter, _arguments); Time.now; end
      def to_s; "<native fn>"; end
    end.new
  end
end
