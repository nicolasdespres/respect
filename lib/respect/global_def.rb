require 'set'

module Respect
  # Global context of the schema definition DSL.
  #
  # This is the base class of all DSL evaluation context. It provides
  # minimal evaluation support. Any methods added to this class will
  # be available in every context of DSL.
  #
  # You can evaluate a block using the {#eval} method. Sub-classes must
  # implement the +evalulation_result+ methods (which must returns the
  # result of the evaluation) or provides their own +eval+ methods.
  #
  # End-users are not supposed to sub-class this class yet. Its API is
  # *experimental*.
  class GlobalDef

    # Remove methods inherited from Object and conflicting with the
    # dynamic methods in CoreStatement.
    %w{hash}.each do |name|
      undef_method name
    end

    class << self

      # Instantiate this evaluation context using the given +args+
      # and evaluate the given +block+ within it.
      def eval(*args, &block)
        new(*args).eval(&block)
      end

      # Return whether the statements declared in this context accept a name
      # as first argument. All classes not including {DefWithoutName}
      # accept names.
      def accept_name?
        !(self < DefWithoutName)
      end

      @@core_contexts = Set.new

      # Call this method in "def" class willing to offer core statements.
      # Do not include {CoreStatements} directly.
      def include_core_statements
        @@core_contexts << self
        include CoreStatements
      end

      # Return the list of all classes including {CoreStatements}.
      def core_contexts
        @@core_contexts
      end

    end

    # Shortcut to {GlobalDef.accept_name?}.
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
      raise NoMethodError, "override me in sub-classes"
    end
  end

end
