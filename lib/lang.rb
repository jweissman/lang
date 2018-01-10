require 'lang/version'
require 'lang/grammar'
require 'lang/tokenizer'
require 'lang/parser'
require 'lang/pattern_matcher'

module Lang
  class LexError < StandardError; end

  class Interpreter
    def initialize(grammar:, composer:)
      @grammar = grammar
      @composer = composer
    end

    def executes(str)
      parse_tree = @grammar.parse(input_string: str)
      @composer.resolve(*parse_tree)
    end
  end

  class Composer
    class << self
      def evaluate(input_string:)
        interpreter = Interpreter.new(grammar: @grammar, composer: self)
        interpreter.executes(input_string)
      end

      def resolve(meth, *children)
        resolved_children = children.map do |child|
          if child.is_a?(Array) # hm
            resolve(*child)
          else
            child
          end
        end

        send(meth, *resolved_children)
      end

      def grammar(g)
        @grammar = g
        true
      end
    end
  end
end
