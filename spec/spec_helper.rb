require 'rspec'
require 'pry'
require 'lang'

include Lang

require 'support/numbers'
require 'support/calculator'

class Letters < Lang::Grammar
  token :string_literal, matches: /[a-zA-Z]+/
  token :space, matches: /\s+/
end

class SimpleNumbers < Lang::Grammar
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
    match.one :value
    match.zero_or_more :factor_prime
  end

  production :factor_prime do |match|
    match.one_of :mult, :div
    match.one :factor
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

  production :value do |match|
    match.token :integer_literal
  end

  token :integer_literal, matches: /[0-9]+/
  token :operator, matches: /[-+\*\/]/
end

class SimpleCalculator < Lang::Composer
  grammar SimpleNumbers

  def term(left, op_and_right=nil)
    val = left
    if op_and_right
      op, right = *op_and_right
      case op.first
      when :add then val + right
      when :subtract then val - right
      else raise "Unknown operator #{operator}"
      end
    else
      val
    end
  end

  def term_prime(*args)
    args
  end

  def factor(left, op_and_right=nil)
    val = left
    if op_and_right
      op, right = *op_and_right
      case op.first
      when :div then val / right
      when :mult then val * right
      else raise "Unknown operator #{operator}"
      end
    else
      val
    end
  end

  def factor_prime(*args)
    args
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

  def operator(op); op  end
  def value(val);   val end

  def integer_literal(val)
    Integer(val)
  end
end
