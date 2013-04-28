module Respect
  # Base class for all DSL evaluation context classes.
  #
  # We can evaluate a block using the {#eval} method. A {DefEvaluator}
  # proxy is used to narrow the evaluation context to a BasicObject so the
  # sub-classes keep Ruby's reflections possibilities without cluttering
  # the DSL itself with many unrelated method names.
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

    # Evaluate the given +block+ in the context of this class through
    # a {DefEvaluator} proxy with this class as target.
    # {#evaluation_result} is called at the end to return the
    # result of this evaluation.
    def eval(&block)
      @def_evaluator ||= DefEvaluator.new(self)
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
