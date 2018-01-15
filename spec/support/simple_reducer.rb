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


