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
