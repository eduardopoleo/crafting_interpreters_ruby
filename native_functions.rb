module NativeFunctions
  def clock
    Class.new do
      def arity; 0; end
      def call; Time.now; end
      def to_s; "<native fn>"; end
    end.new
  end
end
