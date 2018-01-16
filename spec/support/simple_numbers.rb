class SimpleNumbers < Lang::Grammar
  production :expression do |match|
    match.statement
  end

  production :statement do |match|
    match.term
    match.zero_or_one :statement_prime
  end

  production :statement_prime do |match|
    match.one_of :plus, :minus
    match.term
    match.zero_or_one :statement_prime
  end

  production :term do |match|
    match.factor
    match.zero_or_one :term_prime
  end

  production :term_prime do |match|
    match.one_of :astericks, :right_slash
    match.factor
    match.zero_or_one :term_prime
  end

  production :factor do |match|
    match.one_of :value
  end

  production :value do |match|
    match.one_of :substatement, :number
  end

  production :substatement do |match|
    match.left_parens
    match.statement
    match.right_parens
  end

  production :number do |match|
    match.int_lit
  end

  production :plus do |match|
    match.binary_op '+'
  end

  production :minus do |match|
    match.binary_op '-'
  end

  production :astericks do |match|
    match.binary_op '*'
  end

  production :right_slash do |match|
    match.binary_op '/'
  end

  production :left_parens do |match|
    match.parens '('
  end

  production :right_parens do |match|
    match.parens ')'
  end

  token :int_lit, matches: /[0-9]+/
  token :binary_op, matches: /[-\*\+\/]/
  token :parens, matches: /[\(\)]/
end
