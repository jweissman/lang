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
 - [x] `match.maybe?(type)` (optional, predicate [returns `true`/`false`])
 - [x] `match.exactly(*types)` (sequence)
 - [x] `match.and!(type)` (check type matcher 'would' succeed; does _not_ consume tokens)
 - [x] `match.not!(type)` (negation of type matcher; does _not_ consume tokens)
 - [x] `match.total?` (epsilon or empty-string predicate; does not error)
 - [x] `match.assert(bool,msg=nil)` (add an error to the matcher if the condition holds)
 - [x] `match.[production]` (method-missing support for production rule names)
 - [x] `match.[tokens]` (method-missing support for token names)
 - Composer DSL
 - [x] Basic auto-resolution strategy
 - [x] Resolution hooks (`skip_resolution :method`, `after_resolve :method, :except => [ :methods ]`)

## Examples

Let's build a calculator!

```ruby
require 'lang'

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
```

Now we can build a simple evaluator by inheriting from `Lang::Composer`.

Note that 'composition' methods are expected to be instance methods; and that by convention `expression` is the root production.

First, we'll build a reducer that can distill down the huge nested ast we'll get.

```ruby
class SimpleReducer < Lang::Composer
  grammar SimpleNumbers

  def epsilon(*_args)
    nil
  end

  def substatement(_lpn,val,_rpn)
    val
  end

  def statement(left, right=nil)
    gather_left_and_right(left, right)
  end

  def statement_prime(*args)
    args
  end

  def term(left, right=nil)
    gather_left_and_right(left, right)
  end

  def term_prime(*args)
    args
  end

  def factor(left, right=nil)
    gather_left_and_right(left, right)
  end

  def factor_prime(*args)
    args
  end

  def value(val)
    val
  end

  def number(num)
    num
  end

  def int_lit(val)
    Integer(val)
  end

  def binary_op(op)
    op
  end

  def plus(_plus)
    :add
  end

  def minus(_minus)
    :subtract
  end

  def astericks(_astericks)
    :multiply
  end

  def right_slash(_slsh)
    :divide
  end

  def left_parens(*args); end
  def right_parens(*args); end

  def parens(_parns)
    nil
  end

  protected

  def gather_left_and_right(left, op_and_right=nil)
    if op_and_right
      op,right,*rest = *op_and_right
      gathered = [ op, left, right ]
      if rest.compact.any?
        gather_left_and_right(gathered, *rest)
      else
        gathered
      end
    else
      left
    end
  end
end
```

Okay, now we're ready for a simple calculator implementation!


```ruby
class SimpleCalculator
  include Lang::Composition

  def evaluate(input_string:)
    reducer = SimpleReducer.new
    ast = reducer.evaluate(input_string: input_string)
    if ast.is_a?(Array)
      resolve(*ast)
    else
      ast
    end
  end

  protected

  def add(left, right)
    left + right
  end

  def subtract(left, right)
    left - right
  end

  def multiply(left, right)
    left * right
  end

  def divide(left, right)
    left / right
  end
end
```

Now we can use this `Calculator` class to compute simple arithmetic expressions.

```ruby
Calculator.evaluate input_string: '2+3'   # => 5
Calculator.evaluate input_string: '2+3*4' # => 14
Calculator.evaluate input_string: '2+3*(4+1)' # => 17
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
