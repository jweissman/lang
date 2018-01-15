require 'spec_helper'
require 'lang/tokenizer'
require 'lang/grammar'
require 'lang/parser'
require 'lang/pattern_matcher'
require 'support/letters'
require 'support/numbers'
# require 'support/calculator'

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
end
