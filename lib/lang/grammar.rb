module Lang
  class Grammar
    class << self
      attr_reader :tokens

      def token(name, matches:)
        @tokens ||= {}
        @tokens[name] = matches
        true
      end

      def tokenize(input_string:)
        tokenizer = Tokenizer.new(grammar: self)
        tokenizer.extract_tokens(input_string: input_string)
      end

      attr_reader :productions

      def parse(input_string:)
        parser = Parser.new(grammar: self)
        tokens = tokenize(input_string: input_string)
        tree = parser.analyze(tokens: tokens)

        # hand back raw parse tree?
        tree.first # ...
      end

      def production(name, &blk)
        @productions ||= {}
        @productions[name] = blk
        true
      end
    end
  end
end
