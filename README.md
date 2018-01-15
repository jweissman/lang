# lang
[![Code Climate GPA](https://codeclimate.com/github/jweissman/lang/badges/gpa.svg)](https://codeclimate.com/github/jweissman/lang)

## Description

Language-building tools for Ruby!

## Features

 - Grammar DSL
 - [x] `match.one(type)`
 - [x] `match.one_of(*types)`
 - [x] `match.zero_or_more(type)`
 - [x] `match.one_or_more(type)`
 - [ ] `match.maybe?(type)` (optional, predicate [returns `true`/`false`])
 - [ ] `match.exactly(*types)` (sequence)
 - [ ] `match.and(type)` (check type matcher succeeds, but does not consume tokens)
 - [ ] `match.not(type)` (negation, does not consume)
 - Composer DSL
 - [x] Basic auto-resolution strategy
 - [ ] Resolution hooks (`skip_resolution :method`, `after_resolve :method, :except => [ :methods ]`)

## Examples

Let's build a calculator!

```ruby
require 'lang'

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
```

Now we can build a simple evaluator by inheriting from `Lang::Composer`.

Note that 'composition' methods are expected to be instance methods; and that by convention `expression` is the root production.

```ruby
class SimpleCalculator < Lang::Composer
  grammar SimpleNumbers

  def term(left, op_and_right=nil)
    val = left
    if op_and_right
      op, right = *op_and_right
      case op.first
      when :add then val + right
      when :subtract then val - right
      else raise "Unknown operator #{operator}"
      end
    else
      val
    end
  end

  def term_prime(*args)
    args
  end

  def factor(left, op_and_right=nil)
    val = left
    if op_and_right
      op, right = *op_and_right
      case op.first
      when :div then val / right
      when :mult then val * right
      else raise "Unknown operator #{operator}"
      end
    else
      val
    end
  end

  def factor_prime(*args)
    args
  end

  def mult(_sign)
    [ :mult ]
  end

  def div(_sign)
    [ :div ]
  end

  def add(_sign)
    [ :add ]
  end

  def sub(_sign)
    [ :subtract ]
  end

  def operator(op); op  end
  def value(val);   val end

  def integer_literal(val)
    Integer(val)
  end
end
```

Now we can use this `Calculator` class to compute simple arithmetic expressions.

```ruby
Calculator.evaluate input_string: '2+3'   # => 5
Calculator.evaluate input_string: '2+3*4' # => 14
```

## Requirements



## Install

    # Gemfile
    gem 'lang', github: 'jweissman/lang'

## Synopsis

    $ lang

## Copyright

Copyright (c) 2018 Joseph Weissman

See LICENSE.txt for details.
