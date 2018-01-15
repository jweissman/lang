require 'spec_helper'
require 'rspec/mocks'
require 'lang/pattern_matcher'
include Lang

describe PatternMatcher do
  subject(:matcher) do
    described_class.new(
      productions: productions,
      tokens: tokens
    )
  end

  describe 'matching operations' do
    let(:productions) do
      {
        an_apple: ->(match) { match.token(:apple) },
        a_cherry: ->(match) { match.token(:cherry) },
        an_orange: ->(match) { match.token(:orange) },
      }
    end

    let(:tokens) do
      [
        [ :apple,   'red delicious' ],
        [ :apple,   'pink lady' ],
        [ :cherry,  'bing' ],
        [ :orange,  'flo rida' ],
        [ :apple,   'granny smith' ],
        [ :cherry,  'maraschino' ],
      ]
    end

    it 'can match one type' do
      expect{matcher.one(:an_apple)}.to change(matcher,:matches).from([]).to([[:an_apple, [:apple, 'red delicious']]])
    end

    it 'can match one type with method missing' do
      expect{matcher.an_apple}.to change(matcher,:matches).by([[:an_apple, [:apple, 'red delicious']]])
      expect{matcher.an_apple}.to change(matcher,:matches).by([[:an_apple, [:apple, 'pink lady']]])
      expect{matcher.a_cherry}.to change(matcher,:matches).by([[:a_cherry, [:cherry, 'bing']]])
      expect{matcher.an_orange}.to change(matcher,:matches).by([[:an_orange, [:orange, 'flo rida']]])

      expect{matcher.a_cherry}.to change(matcher,:errors).by([
        "Expected a_cherry but could not find it! (next character is [:apple, \"granny smith\"])"
      ])
    end

    it 'can match one of a few types' do
      expect{matcher.one_of(:an_apple,:a_cherry,:an_orange)}.to change(matcher,:matches).by([[:an_apple, [:apple, 'red delicious']]])
      expect{matcher.one_of(:an_apple,:a_cherry,:an_orange)}.to change(matcher,:matches).by([[:an_apple, [:apple, 'pink lady']]])
      expect{matcher.one_of(:an_apple,:a_cherry,:an_orange)}.to change(matcher,:matches).by([[:a_cherry, [:cherry, 'bing']]])
      expect{matcher.one_of(:an_apple,:a_cherry,:an_orange)}.to change(matcher,:matches).by([[:an_orange, [:orange, 'flo rida']]])

      # make it fail
      expect{matcher.one_of(:a_cherry,:an_orange)}.to change(matcher,:errors).by([
        "Attempted to match one of a_cherry, an_orange but could not (next up is [:apple, \"granny smith\"])"
      ])
    end

    it 'can match zero or more' do
      expect{matcher.zero_or_more(:a_cherry)}.not_to change(matcher, :matches)
      expect{matcher.zero_or_more(:an_apple)}.to change(matcher, :matches).by([
        [:an_apple, [:apple, 'red delicious']],
        [:an_apple, [:apple, 'pink lady']]
      ])

      # only fails if you give it not-a-production
      expect{matcher.zero_or_more(:an_onion)}.to raise_error(MatcherError, "Unknown production rule :an_onion (missing definition?)")
    end

    it 'can match one or more' do
      expect{
        matcher.one_or_more(:an_apple)
      }.to change(matcher, :matches).by([
        [:an_apple, [:apple, 'red delicious']],
        [:an_apple, [:apple, 'pink lady']]
      ])

      expect{
        matcher.one_or_more(:a_cherry)
      }.to change(matcher, :matches).by([
        [:a_cherry, [:cherry, 'bing']]
      ])

      expect{
        matcher.one_or_more(:a_cherry)
      }.to change(matcher, :errors).by([
        "Expected at least one a_cherry (next is [:orange, \"flo rida\"])"
      ])
    end
  end
end
