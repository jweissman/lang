class Reference < Struct.new(:name); end
class Database
  def initialize
    @data = {}
  end

  def set(key, val)
    @data[key] = val
  end

  def get(key)
    @data[key]
  end
end

class Calculator < Lang::Composer
  grammar Numbers

  # skip_resolution :statement
  # after_resolution :dereference #, except: :term

  def statement(left, op_and_right=nil)
    if op_and_right
      # binding.pry
      resolved_left = resolve(*left)
      unless resolved_left.is_a?(Reference)
        binding.pry
        raise LexError.new("Expected lhs of assignment (#{left}) to be a reference")
      end
      op, right = *resolve(*op_and_right)
      # binding.pry
      case op.first
      when :assign then database.set(resolved_left.name, resolve(*right))
      else raise "Unknown op #{op}" # ...
      end
    else
      left
    end
  end

  def statement_prime(*args)
    args
  end

  def term(left, op_and_right=nil)
    if op_and_right
      op, right = *op_and_right
      case op.first
      when :add then left + right
      when :subtract then left - right
      else raise "Unknown operator #{operator}"
      end
    else
      left
    end
  end

  def term_prime(*args)
    args
  end

  def factor(left, op_and_right=nil)
    if op_and_right
      op, right = *op_and_right
      case op.first
      when :div then left / right
      when :mult then left * right
      else raise "Unknown operator #{operator}"
      end
    else
      left
    end
  end

  def factor_prime(*args)
    args
  end

  def power(left, op_and_right=nil)
    if op_and_right
      _op,right = *op_and_right
      # assume op is exponentiate...
      left ** right
    else
      left
    end
  end

  def power_prime(*args)
    args
  end

  def number(val)
    val
  end

  def subexpression(*args)
    args[1] # ...could destructure in sign like (_lp,expr,_rp)
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

  def exp(_sign)
    [ :exponentiate ]
  end

  def parens(_paren)
    nil
  end

  def eq(_equals)
    [ :assign ]
  end

  def ident(id)
    # binding.pry
    # _id,key = *id
    Reference[id]
  end

  def identifier(id); id end
  def operator(op); op  end
  def value(val);   val end

  def integer_literal(val)
    Integer(val)
  end

  protected
  def dereference(maybe_ref)
    if maybe_ref.is_a?(Reference)
      p [ :deref!, name: maybe_ref.name ]
      database.get(maybe_ref.name)
    else
      maybe_ref
    end
  end

  private
  def database
    @db ||= Database.new
  end
end