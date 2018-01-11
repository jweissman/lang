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
