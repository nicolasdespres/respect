module Respect
  # Base class for all DSL evaluation context classes.
  #
  # You can evaluate a block using the {#eval} method. A {FakeNameProxy}
  # is used to narrow the evaluation context to a BasicObject so the
  # sub-classes keep Ruby's reflections possibilities without cluttering
  # the DSL itself with many unrelated method names.
  #
  # End-users are not supposed to sub-class this class yet. Its API is
  # *experimental*.
  class BaseDef

    class << self

      # Instantiate this evaluation context using the given +args+
      # and evaluate the given +block+ within it.
      def eval(*args, &block)
        new(*args).eval(&block)
      end

      # Return whether the commands of this context accept a name
      # as first argument. All classes not including {DefWithoutName}
      # accept names.
      def accept_name?
        !(self < DefWithoutName)
      end

    end

    # Shortcut to {BaseDef.accept_name?}.
    def accept_name?
      self.class.accept_name?
    end

    # Evaluate the given +block+ in the context of this class through
    # a {FakeNameProxy} with this class as target.
    # {#evaluation_result} is called at the end to return the
    # result of this evaluation.
    def eval(&block)
      @def_evaluator ||= FakeNameProxy.new(self)
      @def_evaluator.eval(&block)
      evaluation_result
    end

    private

    # Overwrite this method in sub-classes to return the result value
    # of this evaluation context.
    def evaluation_result
      raise NoMethodError, "overwrite me in sub-classes"
    end
  end

end
