require 'spec_helper'

describe Lang::Grammar do
  context 'DSL' do
    describe 'token' do
      it 'creates a token definition' do
        expect(Numbers.tokens.length).to eq(3)
        expect(Numbers.tokens.keys.first).to eq(:integer_literal)
        expect(Numbers.tokens[:integer_literal]).to eq(/[0-9]+/)

        expect(Numbers.tokenize(input_string: '123456')).to eq([
          [ :integer_literal, '123456' ]
        ])

        expect{Numbers.tokenize(input_string: 'abcdef')}.to raise_error(Lang::LexError)
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
          :term, [ :factor, [ :value, [ :number, [ :integer_literal, '1234' ]]]]
        ])
      end

      it 'can match patterns' do
        expect(Numbers.parse(input_string: '1+2-3')).to eq(
          [:term, [:factor, [:value, [ :number, [:integer_literal, "1"]]]],
           [:term_prime,
            [:add, [:operator, "+"]],
            [:term,
             [:factor, [:value, [ :number, [:integer_literal, "2"]]]],
             [:term_prime,
              [:sub, [:operator, "-"]],
              [:term, [:factor, [:value, [ :number, [:integer_literal, "3"]]]]]]]]]
        )
      end
    end
  end

  context 'arithmetic' do
    it 'should match integers' do
      expect(Numbers.parse(input_string: '12345')).to eq(
        [ :term, [ :factor, [ :value, [ :number, [:integer_literal, '12345']]]]]
      )
    end

    it 'should match integer plus integer' do
      expect(Numbers.parse(input_string: '1+2')).to eq(
        [ :term,
           [ :factor, [ :value, [ :number, [ :integer_literal, "1" ]]]],
           [:term_prime,
            [:add, [:operator, "+"]],
            [:term, [:factor, [:value, [ :number, [:integer_literal, "2"]]]]]
        ]]
      )
    end

    it 'should compose' do
      expect(Calculator.evaluate(input_string: '2+2')).to eq(4)
      expect(Calculator.evaluate(input_string: '2+3+4')).to eq(9)
      expect(Calculator.evaluate(input_string: '2+3-4')).to eq(1)
      expect(Calculator.evaluate(input_string: '2*3-4')).to eq(2)
      expect(Calculator.evaluate(input_string: '5+2*3')).to eq(11)
      expect(Calculator.evaluate(input_string: '(5+2)*3')).to eq(21)
      expect(Calculator.evaluate(input_string: '1+2*3-5')).to eq(2)
    end
  end
end
