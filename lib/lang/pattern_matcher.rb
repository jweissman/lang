require 'forwardable'
require 'lang/token_stream_analyst'
module Lang
  class MatcherError < StandardError; end
  class PatternMatcher
    extend Forwardable

    attr_reader :analyst, :matches
    attr_reader :productions, :errors

    def_delegators :analyst, :total?, :peek, :check, :consume!, :consume_multiple!, :consumed_tokens_count, :tokens

    def initialize(productions:, tokens:)
      @productions = productions
      @analyst = TokenStreamAnalyst.new(tokens: tokens)

      @matches = []
      @errors = []
    end

    def token(tkn, val=nil)
      return if failed?
      if check tkn
        token!(tkn, val)
      else
        error "Expected token #{tkn} but got #{peek}"
      end
      self
    end

    def one(type)
      return if failed?
      submatcher = run_submatcher(type: type)
      if submatcher.failed?
        if !total? #peek
          error "Expected #{type} but could not find it! (next character is #{peek})"
        else
          error "Expected #{type} but could not find it! (end of stream)"
        end
      else
        consume_multiple!(count: submatcher.consumed_tokens_count)
        match [ type, *submatcher.matches ]
      end
      self
    end


    def zero_or_one(type)
      return if failed?
      if !(one?(type))
        # it's okay..
      else
        one type
      end
      self
    end

    def zero_or_more(type)
      return if failed?
      if !one?(type)
        # no errors, it's okay...
      else
        one type
        zero_or_more type
      end
      self
    end

    def one_or_more(type)
      return if failed?
      if !one?(type)
        error "Expected at least one #{type} (next is #{peek})"
      else
        one type
        zero_or_more type
      end
      self
    end

    def maybe?(type)
      present = !!(one?(type))
      one(type) if present
      present
    end

    def exactly(*types)
      return if failed?
      types.each do |type|
        one(type)
      end

      if failed?
        # add more errors?
        error "Expected to find sequence of types #{types} but failed"
      end

      self
    end

    def one_of(*types)
      return if failed?
      type = types.detect(&method(:one?))
      if type
        one type
      else
        error "Attempted to match one of #{types.join(', ')} but could not (next up is #{peek})"
      end
      self
    end

    def and!(type)
      # like maybe, but don't consume
      present = !!(one?(type))
      if !present
        error "Expected #{type} but could not find it!"
      end
      self
    end

    def not!(type)
      absent = !(one?(type))
      if !absent
        error "Expected not to find #{type} but found it!"
      end
      self
    end

    def assert(condition,msg=nil)
      if !condition
        error msg
      end
      self
    end

    def succeeded?
      !failed?
    end

    def failed?
      @errors.any?
    end

    def method_missing(sym,*args,&blk)
      if @productions.keys.include?(sym)
        one(sym)
      else # assume token?
        token(sym,*args)
      # else
      #   super(sym,*args,&blk)
      end
    end

    protected

    def match(m)
      @matches << m
    end

    def error(e)
      @errors << e
    end

    def one?(type)
      submatcher = run_submatcher(type: type)
      !submatcher.failed?
    end

    def token!(tkn,val)
      if !val.nil? && !(check(tkn) == val)
        error "Expected #{tkn} to be #{val} but was #{check tkn}"
        return
      end

      match consume!(tkn)
    end

    private

    def build_submatcher
      self.class.new(productions: @productions, tokens: tokens)
    end

    def run_submatcher(type:)
      raise MatcherError.new("Unknown production rule :#{type} (missing definition?)") unless @productions.key?(type)
      type_def = @productions[type]
      submatcher = build_submatcher
      type_def.call(submatcher)
      submatcher
    end
  end
end
