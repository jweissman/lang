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

    it 'can match tokens' do
      expect{matcher.token(:apple, 'red delicious')}.to change(matcher,:matches).by([[ :apple, 'red delicious' ]])
      expect{matcher.token(:apple, 'pink lady')}.to change(matcher,:matches).by([[ :apple, 'pink lady' ]])
      expect{matcher.token(:apple, 'fuji')}.to change(matcher,:errors).by(["Expected token apple but got [:cherry, \"bing\"]"])
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

    it 'can match optionally' do
      expect{
        matcher.maybe?(:an_apple)
      }.to change(matcher, :matches).by([
        [ :an_apple, [ :apple, 'red delicious' ]]
      ])

      # basically zero_or_one, but can act as predicate (return a bool)
      expect(matcher.maybe?(:an_orange)).to eq(false)
      expect(matcher.maybe?(:an_apple)).to eq(true)
    end

    it 'can match a sequence' do
      expect{
        matcher.exactly(:an_apple, :an_apple, :a_cherry, :an_orange, :an_apple)
      }.to change(matcher, :matches).by([
        [ :an_apple, [ :apple, 'red delicious' ]],
        [ :an_apple, [ :apple, 'pink lady' ]],
        [:a_cherry, [:cherry, 'bing']],
        [:an_orange, [:orange, 'flo rida']],
        [ :an_apple, [ :apple, 'granny smith' ]],
      ])

      expect{
        matcher.exactly(:a_cherry,:a_cherry,:a_cherry)
      }.to change(matcher,:errors).by([
        "Expected a_cherry but could not find it! (end of stream)",
        "Expected to find sequence of types [:a_cherry, :a_cherry, :a_cherry] but failed"
      ])
    end

    it 'can match and [predicate]' do
      # these just pass/fail without consuming
      # i.e., they add errors if they fail but don't add to matches
      # perform the scan but don't consume
      expect{
        matcher.and!(:an_apple)
      }.not_to change(matcher, :matches)

      expect{matcher.and!(:a_cherry)}.to change(matcher, :errors).by([
        "Expected a_cherry but could not find it!"
      ])

      # can keep matching the same one over and over
      expect{matcher.and!(:an_apple)}.not_to change(matcher,:errors)
      expect{matcher.and!(:an_apple)}.not_to change(matcher,:errors)
      expect{matcher.and!(:an_apple)}.not_to change(matcher,:errors)
      expect{matcher.and!(:an_apple)}.not_to change(matcher,:errors)
      expect{matcher.and!(:an_orange)}.to change(matcher,:errors).by([
        "Expected an_orange but could not find it!"
      ])
      # expect(matcher.and(:an_apple)).to eq(true)
      # expect(matcher.and(:an_apple)).to eq(true)
      # expect(matcher.and(:an_apple)).to eq(true)
    end

    it 'can match not [predicate]' do
      # expect(matcher.not(:a_cherry)).to eq(true)
      expect{matcher.not!(:a_cherry)}.not_to change(matcher,:matches)

      expect{matcher.not!(:an_apple)}.to change(matcher,:errors).by([ "Expected not to find an_apple but found it!" ])

      expect{matcher.not!(:a_cherry)}.not_to change(matcher,:errors)
      expect{matcher.not!(:a_cherry)}.not_to change(matcher,:errors)
      expect{matcher.not!(:a_cherry)}.not_to change(matcher,:errors)
      expect{matcher.not!(:a_cherry)}.not_to change(matcher,:errors)
      expect{matcher.not!(:a_cherry)}.not_to change(matcher,:errors)
    end
  end
end
