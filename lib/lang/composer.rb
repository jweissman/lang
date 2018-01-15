require 'lang/composition'
module Lang
  class Composer
    include Lang::Composition
    def evaluate(input_string:)
      grammar = self.class.instance_variable_get(:@grammar)
      interpreter = Interpreter.new(grammar: grammar, composer: self)
      interpreter.executes(input_string)
    end

    class << self
      def grammar(g)
        @grammar = g
        true
      end
    end
  end
end
