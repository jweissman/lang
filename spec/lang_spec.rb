require 'spec_helper'

describe Lang::Grammar do
  context 'DSL' do
    describe 'token' do
      it 'creates a token definition' do
        expect(Numbers.tokens.keys).to include(:integer_literal)
        expect(Numbers.tokens[:integer_literal]).to eq(/[0-9]+/)
        expect(Numbers.tokenize(input_string: '123456')).to eq([
          [ :integer_literal, '123456' ]
        ])
      end

      it 'can handle multiple token definitions' do
        expect(Letters.tokenize(input_string: 'abc def  ghi')).to eq([
          [ :string_literal, 'abc' ],
          [ :space, ' '],
          [ :string_literal, 'def' ],
          [ :space, '  '],
          [ :string_literal, 'ghi' ],
        ])
      end
    end

    describe 'production' do
      it 'can match tokens' do
        expect(Numbers.parse(input_string: '1234')).to eq([
          :statement, [ :term, [ :factor, [ :power, [ :value, [ :number, [ :integer_literal, '1234' ]]]]]]
        ])
      end

      it 'can match patterns' do
        expect(Numbers.parse(input_string: '1+2-3')).to eq(
         [:statement,
          [:term, [:factor, [ :power, [:value, [ :number, [:integer_literal, "1"]]]]],
           [:term_prime,
            [:add, [:operator, "+"]],
            [:term,
             [:factor, [ :power, [:value, [ :number, [:integer_literal, "2"]]]]],
             [:term_prime,
              [:sub, [:operator, "-"]],
              [:term, [:factor, [ :power, [:value, [ :number, [:integer_literal, "3"]]]]]]]]]]]
        )
      end
    end
  end

  context 'arithmetic' do
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

    let(:calculator) { Calculator.new }

    it 'should compose respecting operator precedence' do
      expect(calculator.evaluate(input_string: '2+2')).to eq(4)
      expect(calculator.evaluate(input_string: '2+3')).to eq(5)
      expect(calculator.evaluate(input_string: '2+3*4')).to eq(14)
      expect(calculator.evaluate(input_string: '2+3+4')).to eq(9)
      expect(calculator.evaluate(input_string: '2+3-4')).to eq(1)
      expect(calculator.evaluate(input_string: '2*3-4')).to eq(2)
      expect(calculator.evaluate(input_string: '5+2*3')).to eq(11)
      expect(calculator.evaluate(input_string: '1+2*3-5')).to eq(2)
    end

    it 'composes subexpressions' do
      expect(calculator.evaluate(input_string: '(5+2)*3')).to eq(21)
    end

    it 'composes exponents' do
      expect(calculator.evaluate(input_string: '2**3')).to eq(8)
      expect(calculator.evaluate(input_string: '2**(3+1)')).to eq(16)
      expect(calculator.evaluate(input_string: '2**3+1')).to eq(9)
      expect(calculator.evaluate(input_string: '2**3+1*2')).to eq(10)
    end

    xit 'composes variables' do
      expect(calculator.evaluate(input_string: 'a=2')).to eq(2)
      # expect(calculator.evaluate(input_string: 'a+a')).to eq(4)
    end

    it 'passes through errors' do
      expect{
        calculator.evaluate(input_string: '1+2*3-')
      }.to raise_error(LexError)

      expect{
        calculator.evaluate(input_string: '(1+2*3')
      }.to raise_error(LexError)
    end
  end
end
