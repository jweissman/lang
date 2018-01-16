module Lang
  class Tokenizer
    def initialize(grammar:, input_string:)
      @grammar = grammar
      @input_string = input_string
    end

    def extract_tokens(input_string: @input_string)
      scanner = StringScanner.new(input_string)
      tokens = []
      until scanner.eos?
        extract_token(scanner: scanner, tokens: tokens)
      end
      return tokens
    end

    protected

    def extract_token(scanner:, tokens:)
      matched_token = match_token(scanner: scanner)
      if matched_token
        tokens << [ matched_token, scanner.matched ]
      else
        raise LexError.new("Unexpected character at #{scanner.pos}: #{@input_string[scanner.pos]}")
      end
    end

    def match_token(scanner:)
      token_names.detect do |token_name|
        regex = @grammar.tokens[token_name]
        scanner.scan(regex)
      end
    end

    private

    def token_names
      @grammar.tokens.keys
    end
  end
end
