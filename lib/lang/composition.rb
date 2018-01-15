module Lang
  module Composition
    def self.included(base)
      base.include(Lang::Composition::InstanceMethods)
      base.extend(Lang::Composition::ClassMethods)
    end

    module InstanceMethods
      def resolve(meth, *children)
        if self.class.resolutions_to_skip.any? && \
            self.class.resolutions_to_skip.include?(meth)
          send(meth, *children)
        else
          send(meth, *resolve_children(meth, *children))
        end
      end

      protected

      def resolve_children(meth, *children)
        children.map do |child|
          if child.is_a?(Array)
            resolve_child(meth, child)
          else
            child
          end
        end
      end

      def resolve_child(meth, child)
        resolved_child = resolve(*child)
        resolved_child = run_post_resolve_hooks(meth, resolved_child)
        resolved_child
      end

      def run_post_resolve_hooks(meth, child)
        post_resolve_hooks_for(meth).each do |method:, **opts|
          child = send(method, child)
        end
        child
      end

      def post_resolve_hooks_for(meth)
        if self.class.post_resolution_hooks.any?
          self.class.post_resolution_hooks.select do |method:, except:|
            meth != except
          end
        else
          []
        end
      end
    end

    module ClassMethods
      def skip_resolution(method)
        resolutions_to_skip << method
      end

      def after_resolution(method, **opts)
        except = opts.delete(:except) { [] }
        post_resolution_hooks << { method: method, except: except }
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
