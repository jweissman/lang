require 'lang/version'
require 'lang/grammar'
require 'lang/tokenizer'
require 'lang/parser'
require 'lang/pattern_matcher'
require 'lang/composer'

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
end
