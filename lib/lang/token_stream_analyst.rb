module Lang
  class TokenStreamAnalyst
    attr_reader :consumed_tokens_count, :tokens
    def initialize(tokens:)
      raise "TokenStreamAnalyst must have at least empty list of tokens (can't be nil)" if tokens.nil?
      @tokens = tokens.clone
      @consumed_tokens_count = 0
    end

    def total?
      @tokens.empty?
    end

    def peek
      @tokens.first
    end

    def check(expected_type)
      actual_type, data = *peek
      if actual_type == expected_type
        data
      else
        false
      end
    end

    def consume!(token_kind)
      @consumed_tokens_count += 1
      unless check(token_kind)
        raise "Expected to consume #{token_kind} but got #{peek}"
      end
      @tokens.shift
    end

    def consume_multiple!(count:)
      @consumed_tokens_count += count
      @tokens.shift(count)
    end
  end
end
