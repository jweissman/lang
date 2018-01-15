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

