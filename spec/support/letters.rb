class Letters < Lang::Grammar
  token :string_literal, matches: /[a-zA-Z]+/
  token :space, matches: /\s+/
end
