require 'spec_helper'
require 'lang'
include Lang

require 'support/simple_numbers'
require 'support/simple_calculator'

require 'support/numbers'
require 'support/calculator'

describe Lang do
  context 'parsing arithmetic' do
    it 'should match integers' do
      expect(Numbers.parse(input_string: '12345')).to eq(
        [ :statement, [ :term, [ :factor, [ :power, [ :value, [ :number, [:integer_literal, '12345']]]]]]]
      )
    end

    it 'should match integer plus integer' do
      expect(Numbers.parse(input_string: '1+2')).to eq(
        [ :statement,
        [ :term,
           [ :factor, [ :power, [ :value, [ :number, [ :integer_literal, "1" ]]]]],
           [:term_prime,
            [:add, [:operator, "+"]],
            [:term, [:factor, [ :power, [:value, [ :number, [:integer_literal, "2"]]]]]]
        ]]]
      )
    end


    let(:simple_calculator) { SimpleCalculator.new }

    it 'should compose respecting operator precedence' do
      expect(simple_calculator.evaluate(input_string: '2+2')).to eq(4)
      expect(simple_calculator.evaluate(input_string: '2+3')).to eq(5)
      expect(simple_calculator.evaluate(input_string: '2+3*4')).to eq(14)
      expect(simple_calculator.evaluate(input_string: '2+3+4')).to eq(9)
      expect(simple_calculator.evaluate(input_string: '2+3-4')).to eq(1)
      expect(simple_calculator.evaluate(input_string: '2*3-4')).to eq(2)
      expect(simple_calculator.evaluate(input_string: '5+2*3')).to eq(11)
      expect(simple_calculator.evaluate(input_string: '1+2*3-5')).to eq(2)
      expect(simple_calculator.evaluate(input_string: '2+3*(4+1)')).to eq(17)
    end

    let(:calculator) { Calculator.new }

    it 'composes subexpressions' do
      expect(calculator.evaluate(input_string: '(5+2)*3')).to eq(21)
    end

    it 'composes exponents' do
      expect(calculator.evaluate(input_string: '2**3')).to eq(8)
      expect(calculator.evaluate(input_string: '2**(3+1)')).to eq(16)
      expect(calculator.evaluate(input_string: '2**3+1')).to eq(9)
      expect(calculator.evaluate(input_string: '2**3+1*2')).to eq(10)
    end

    it 'composes variables' do
      expect(calculator.evaluate(input_string: 'a=2')).to eq(2)
      expect(calculator.evaluate(input_string: 'a+a')).to eq(4)
      expect(calculator.evaluate(input_string: 'b=a+5')).to eq(7)
      expect(calculator.evaluate(input_string: 'a*b')).to eq(14)
      expect(calculator.evaluate(input_string: 'b')).to eq(7)

      # undefined var 'c'
      expect{calculator.evaluate(input_string: 'c+3')}.to raise_error(CalcError)
      expect{calculator.evaluate(input_string: 'd*6')}.to raise_error(CalcError)
    end

    it 'passes through errors' do
      expect{
        calculator.evaluate(input_string: '1+2*3-')
      }.to raise_error(ParseError)

      expect{
        calculator.evaluate(input_string: '(1+2*3')
      }.to raise_error(ParseError)
    end
  end
end
