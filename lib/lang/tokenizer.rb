module Lang
  class Tokenizer
    def initialize(grammar:)
      @grammar = grammar
    end

    def extract_tokens(input_string:)
      scanner = StringScanner.new(input_string)
      tokens = []
      until scanner.eos?
        found_match = @grammar.tokens.detect do |token_name, token_regex|
          if scanner.scan(token_regex)
            tokens << [ token_name, scanner.matched ]
          end
        end

        unless found_match
          raise LexError.new("Unexpected character at #{scanner.pos}: #{input_string[scanner.pos]}")
        end
      end
      return tokens
    end
  end
end
