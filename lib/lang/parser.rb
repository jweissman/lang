module Lang
  class Parser
    def initialize(grammar:)
      @grammar = grammar
    end

    def analyze(tokens:, root: :expression)
      if @grammar.productions.key?(root)
        method = @grammar.productions[root]
        analyst = build_matcher(tokens)
        method.call(analyst)
        analyst.matches
      end
    end

    protected

    def build_matcher(tokens)
      PatternMatcher.new(grammar: @grammar, tokens: tokens.dup)
    end
  end
end
