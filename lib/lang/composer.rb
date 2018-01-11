module Lang
  class Composer
    def evaluate(input_string:)
      grammar = self.class.instance_variable_get(:@grammar)
      interpreter = Interpreter.new(grammar: grammar, composer: self)
      interpreter.executes(input_string)
    end

    def resolve(meth, *children)
      if self.class.resolutions_to_skip.any? && \
          self.class.resolutions_to_skip.include?(meth)
        send(meth, *children)
      else
        resolved_children = children.map do |child|
          if child.is_a?(Array) # hm
            resolved_child = resolve(*child)
            if self.class.post_resolution_hooks.any?
              self.class.post_resolution_hooks.each do |method:, except:|
                resolved_child = send(method, resolved_child) #hook.call(child)
              end
            end
            resolved_child
          else
            child
          end
        end

        send(meth, *resolved_children)
      end
    end

    class << self
      # attr_reader :resolutions_to_skip, :post_resolution_hooks

      def grammar(g)
        @grammar = g
        true
      end

      def skip_resolution(method)
        resolutions_to_skip << method
        # todo
      end

      def after_resolution(method, **opts)
        except = opts.delete(:except) { [] }
        post_resolution_hooks << { method: method, except: except }
        # todo
      end

      def resolutions_to_skip
        @resolutions_to_skip ||= []
      end

      def post_resolution_hooks
        @post_resolution_hooks ||= []
      end
    end
  end
end
