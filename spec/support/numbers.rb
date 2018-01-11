class Numbers < Lang::Grammar
  production :expression do |match|
    match.one :statement
  end

  production :statement do |match|
    match.one :term
    match.zero_or_one :statement_prime
  end

  production :statement_prime do |match|
    match.one :eq
    match.one :statement
  end

  production :term do |match|
    match.one :factor
    match.zero_or_one :term_prime
  end

  production :term_prime do |match|
    match.one_of :add, :sub
    match.one :term
  end

  production :factor do |match|
    match.one :power
    match.zero_or_one :factor_prime
  end

  production :factor_prime do |match|
    match.one_of :mult, :div
    match.one :factor
  end

  production :power do |match|
    match.one :value
    match.zero_or_one :power_prime
  end

  production :power_prime do |match|
    match.one :exp
    match.one :power
  end

  production :value do |match|
    match.one_of :ident, :number, :subexpression
  end

  production :subexpression do |match|
    match.token :parens, '('
    match.one :term
    match.token :parens, ')'
  end

  production :number do |match|
    match.token :integer_literal
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

  production :eq do |match|
    match.token :operator, '='
  end

  production :exp do |match|
    match.token :operator, '**'
  end

  production :ident do |match|
    match.token :identifier
  end

  token :identifier, matches: /[a-zA-Z][a-zA-Z0-9]*/
  token :integer_literal, matches: /[0-9]+/
  token :operator, matches: /\*\*|[-+\*\/]|[=]/
  token :parens, matches: /[\(\)]/
end

