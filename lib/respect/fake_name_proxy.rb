module Respect
  # The evaluation proxy used for the DSL.
  #
  # This class sends all methods it receives to the target object it has
  # received when initialized.
  #
  # If the target's response to +accept_name?+ is +false+, this proxy
  # passes a +nil+ value as first argument to target's dynamic methods
  # and target's methods expecting a name as first argument.
  #
  # This is useful to factor method code that should work in two different
  # contexts. For instance, in the context of an object schema primitive
  # statements expect a name as first argument whereas in the context of an
  # array schema they do not.
  #
  #   ObjectSchema.define do |s|
  #     s.integer "age", greater_than: 0
  #   end
  #   ArraySchema.define do |s|
  #     # FakeNameProxy passes +nil+ here as value for the +name+ argument.
  #     s.integer greater_than: 0
  #   end
  #
  # To factor this code, we define the +integer+ method in a module included
  # in both context classes.
  #
  #   module CoreStatements
  #     def integer(name, options = {})
  #       update_context name, IntegerSchema.define(options)
  #     end
  #   end
  #   class ObjectDef
  #     include CoreStatements
  #     def accept_name?; true; end
  #     def update_context(name, schema)
  #       @object_schema[name] = schema
  #     end
  #   end
  #   class ArrayDef
  #     include CoreStatements
  #     def accept_name?; false; end
  #     def update_context(name, schema)
  #       @array_schema.item = schema
  #     end
  #   end
  #
  # The +update_context+ method simply ignored the name argument in ArrayDef
  # because it does not make any sens in this context.
  class FakeNameProxy < BasicObject

    def initialize(target)
      @target = target
    end

    # Return the DSL context object where the evaluation takes place.
    attr_reader :target

    def method_missing(symbol, *args, &block)
      if respond_to_missing?(symbol, false)
        # If the target's default behavior for its methods is to not accept a name as
        # first argument (this is the case for ArrayDef), we introspect the method
        # to decide whether we have to send a nil name as first argument.
        if should_fake_name?
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
      @target.respond_to?(symbol)
    end

    # Evaluate the given +block+ in the context of this class and pass it this
    # instance as argument and returns the value returned by the block.
    def eval(&block)
      block.call(self)
    end

    private

    def dynamic_method?(symbol)
      !@target.methods.include?(symbol)
    end

    def has_name_param?(method)
      !method.parameters.empty? && method.parameters.first.last == :name
    end

    def should_fake_name?
      @target.respond_to?(:accept_name?) && !@target.accept_name?
    end
  end
end
