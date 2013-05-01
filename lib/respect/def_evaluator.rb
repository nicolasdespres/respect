module Respect
  # The evaluation proxy used for the DSL.
  #
  # This class sends all methods it receives to the target object it has
  # received when initialized.
  #
  # This proxy has the following goals:
  # 1. Provide two facades to DSL methods: one with a name as first argument
  #    and one without. See the example below.
  # 1. Evaluate user block in the context of a BasicObject without
  #    restricting all the DSL classes to be a sub-class of BasicObject
  #    this way users can still use Ruby's reflection features via the
  #    {#target} method.
  #
  # The problem is that we have to write two versions of an +integer+ method
  # in to different context. The code of the two versions is almost the same.
  #
  #   class ObjectDef
  #     def integer(name, options = {})
  #       # code...
  #     end
  #   end
  #
  #   class ArrayDef
  #     def integer(options = {})
  #       # same code...
  #     end
  #   end
  #
  # Thanks to this proxy users only have to define one +integer+ method like
  # this:
  #
  #   module Helper
  #     def integer(name, options = {})
  #       # code which handle the case where name is nil
  #     end
  #   end
  #   Respect.extend_dsl_with Helper
  #
  # If the target {BaseDef.accept_name?} method returns +false+, this proxy
  # sends +nil+ as first argument to:
  # - static methods expecting a name as first argument
  # - dynamic methods.
  class DefEvaluator < BasicObject

    def initialize(target)
      unless target.is_a?(::Respect::BaseDef)
        ::Kernel.raise(::ArgumentError,
          "'#{target}:#{target.class}' must be a BaseDef object")
      end
      @target = target
    end

    # Return the DSL context object where the evaluation takes place.
    attr_reader :target

    def method_missing(symbol, *args, &block)
      if respond_to_missing?(symbol, false)
        # If the target's default behavior for its methods is to not accept a name as
        # first argument (this is the case for ArrayDef), we introspect the method
        # to decide whether we have to send a nil name as first argument.
        if !@target.class.accept_name?
          method = @target.method(symbol)
        else
          method = nil
        end
        # If we have a method and this method is either dynamic or expects a name as its first parameter.
        if method && (dynamic_method?(symbol) || has_name_param?(method))
          args.insert(0, nil)
          begin
            method.call(*args, &block)
          rescue ::ArgumentError => e
            # Decrements argument number mentioned in the message by one.
            message = e.message.sub(/ \((\d+) for (\d+)\)$/) do |match|
              # FIXME(Nicolas Despres): Not sure if this class is still
              # re-entrant since we use $1 and $2. I could not find a way to access
              # to the data matched by sub.
              " (#{$1.to_i - 1} for #{$2.to_i - 1})"
            end
            ::Kernel.raise(::ArgumentError, message)
          end
        else
          @target.public_send(symbol, *args, &block)
        end
      else
        super
      end
    end

    def respond_to_missing?(symbol, include_all)
      # We ignore include_all since we are only interested in non-private methods.
      @target.respond_to?(symbol) && !::Object.new.respond_to?(symbol)
    end

    # Evaluate the given +block+ in the context of this class and pass it this
    # instance as argument and returns the value returned by the block.
    def eval(&block)
      if block.arity != 1
        ::Kernel.raise(::ArgumentError,
          "given block must take one argument not #{block.arity}")
      end
      block.call(self)
    end

    private

    def dynamic_method?(symbol)
      !@target.methods.include?(symbol)
    end

    def has_name_param?(method)
      !method.parameters.empty? && method.parameters.first.last == :name
    end
  end
end
