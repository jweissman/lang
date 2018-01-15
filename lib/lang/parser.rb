module Lang
  class ParseError < StandardError; end
  class Parser
    def initialize(grammar:)
      @grammar = grammar
    end

    def analyze(tokens:, root: :expression)
      if @grammar.productions.key?(root)
        method = @grammar.productions[root]
        analyst = build_matcher(tokens)
        method.call(analyst)
        unless analyst.succeeded? && analyst.total?
          raise ParseError.new("Parse of tokens #{tokens} failed (maybe unexpected content?) -- matches so far: #{analyst.matches.join(';')}")
        end
        analyst.matches
      end
    end

    protected

    def build_matcher(tokens)
      PatternMatcher.new(productions: @grammar.productions, tokens: tokens.dup)
    end
  end
end
