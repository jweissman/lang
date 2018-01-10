require 'rspec'
require 'pry'
require 'lang'

include Lang

class Letters < Lang::Grammar
  token :string_literal, matches: /[a-zA-Z]+/
  token :space, matches: /\s+/
end

class Numbers < Lang::Grammar
  production :expression do |match|
    match.one :term
  end

  production :term do |match|
    match.one :factor
    match.zero_or_more :term_prime
  end

  production :term_prime do |match|
    match.one_of :add, :sub
    match.one :term
  end

  production :factor do |match|
    match.one :power
    match.zero_or_more :factor_prime
  end

  production :factor_prime do |match|
    match.one_of :mult, :div
    match.one :factor
  end

  production :power do |match|
    match.one :value
    match.zero_or_more :power_prime
  end

  production :power_prime do |match|
    match.one :exp
    match.one :power
  end

  production :value do |match|
    match.one_of :number, :subexpression
  end

  production :subexpression do |match|
    match.token :parens, '('
    match.one :term
    match.token :parens, ')'
  end

  production :number do |match|
    match.token :integer_literal
  end

  production :add do |match|
    match.token :operator, '+'
  end

  production :sub do |match|
    match.token :operator, '-'
  end

  production :mult do |match|
    match.token :operator, '*'
  end

  production :div do |match|
    match.token :operator, '/'
  end

  production :exp do |match|
    match.token :operator, '**'
  end

  token :integer_literal, matches: /[0-9]+/
  token :operator, matches: /\*\*|[-+\*\/]/
  token :parens, matches: /[\(\)]/
end

class Calculator < Lang::Composer
  grammar Numbers

  class << self
    def term(left, op_and_right=nil)
      if op_and_right
        op, right = *op_and_right
        case op.first
        when :add then left + right
        when :subtract then left - right
        else raise "Unknown operator #{operator}"
        end
      else
        left
      end
    end

    def term_prime(*args)
      args
    end

    def factor(left, op_and_right=nil)
      if op_and_right
        op, right = *op_and_right
        case op.first
        when :div then left / right
        when :mult then left * right
        else raise "Unknown operator #{operator}"
        end
      else
        left
      end
    end

    def factor_prime(*args)
      args
    end

    def power(left, op_and_right=nil)
      if op_and_right
        _op,right = *op_and_right
        # assume op is exponentiate...
        left ** right
      else
        left
      end
    end

    def power_prime(*args)
      args
    end

    def number(val)
      val
    end

    def subexpression(*args)
      args[1] # ...could destructure in sign like (_lp,expr,_rp)
    end

    def mult(_sign)
      [ :mult ]
    end

    def div(_sign)
      [ :div ]
    end

    def add(_sign)
      [ :add ]
    end

    def sub(_sign)
      [ :subtract ]
    end

    def exp(_sign)
      [ :exponentiate ]
    end

    def parens(_paren)
      nil
    end

    def operator(op); op  end
    def value(val);   val end

    def integer_literal(val)
      Integer(val)
    end
  end
end
