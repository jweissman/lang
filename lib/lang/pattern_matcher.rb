module Lang
  class PatternMatcher
    attr_reader :matches, :consumed_tokens_count
    def initialize(grammar:, tokens:)
      @grammar = grammar
      @tokens = tokens.dup
      @matches = []
      @errors = []

      @consumed_tokens_count = 0
    end

    def token(tkn, val=nil)
      return if failed?
      if check tkn
        if !val.nil? && !(check(tkn) == val)
          error "Expected #{tkn} to be #{val} but was #{check tkn}"
          return
        end

        match consume!(tkn)
      else
        error "Expected token #{tkn} but got #{peek}"
      end
    end

    def one(type)
      return if failed?
      type_def = @grammar.productions[type]
      sub_analyst = build_sub_analyst
      type_def.call(sub_analyst)
      if sub_analyst.failed?
        error "Expected #{type} but could not find it! (next character is #{peek})"
      else
        @consumed_tokens_count += sub_analyst.consumed_tokens_count
        @tokens.shift(sub_analyst.consumed_tokens_count)
        match [ type, *sub_analyst.matches ]
      end
    end

    def zero_or_more(type)
      return if failed?
      # p [ :zero_or_more, type: type ]
      type_def = @grammar.productions[type]
      sub_analyst = build_sub_analyst
      type_def.call(sub_analyst)
      if sub_analyst.failed?
        # no errors, it's okay...
      else
        @consumed_tokens_count += sub_analyst.consumed_tokens_count
        @tokens.shift(sub_analyst.consumed_tokens_count)
        match [ type, *sub_analyst.matches ]
        zero_or_more(type)
      end
    end

    def one_or_more(type)
      return if failed?
      # p [ :one_or_more, type: type ]
      type_def = @grammar.productions[type]
      sub_analyst = build_sub_analyst
      type_def.call(sub_analyst)
      if sub_analyst.failed?
        error "Expected at least one #{type} (next is #{peek})"
      else
        @consumed_tokens_count += sub_analyst.consumed_tokens_count
        match [ type, *sub_analyst.matches ]
        @tokens.shift(sub_analyst.consumed_tokens_count)
        # follow_subanalysis(type:, subanalyst: sub_analyst)
        zero_or_more(type) # hmmm
      end
      true
    end

    def one_of(*types)
      return if failed?
      # p [ :one_of, types: types ]
      matched_type = types.detect(&method(:one?))

      if matched_type
        type_def = @grammar.productions[matched_type]
        sub_analyst = build_sub_analyst
        type_def.call(sub_analyst)
        # just assume it worked???
        @consumed_tokens_count += sub_analyst.consumed_tokens_count
        match [ matched_type, *sub_analyst.matches ]
        @tokens.shift(sub_analyst.consumed_tokens_count)
      else
        error "Attempted to match one of #{types.join(', ')} but could not (next up is #{peek})"
      end
    end

    def succeeded?
      !failed? # && tokens.empty?
    end

    def total?
      @tokens.empty?
    end

    def failed?
      @errors.any?
    end

    protected
    def match(m)
      # p [ :match!, m ]
      @matches << m
    end

    def error(e)
      @errors << e
    end

    def one?(type)
      type_def = @grammar.productions[type]
      sub_analyst = build_sub_analyst
      type_def.call(sub_analyst)
      !sub_analyst.failed?
    end

    def build_sub_analyst
      self.class.new(grammar: @grammar, tokens: @tokens.dup)
    end

    private
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
  end
end
