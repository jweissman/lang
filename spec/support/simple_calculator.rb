require 'support/simple_reducer'
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
