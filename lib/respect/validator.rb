module Respect
  # A schema validator.
  #
  # Validator are an extensible way to validate certain properties of
  # a schema. There are many validators available in this library (see
  # all the sub-classes of this class).
  #
  # You can attach a validator to any schema through its options
  # parameters when initializing it. Any schema including the
  # {HasConstraints} module will execute them when its {Schema#validate}
  # method is called.
  #
  # Example:
  #   # Will call GreaterThanValidator.new(42).validate(-1)
  #   IntegerSchema.define(greater_than: 42).validate?(-1)     #=> true
  #
  # The validator API is *experimental* so it is not recommended to
  # write your own.
  class Validator

    class << self
      # Turn this validator class name into a constraint name.
      def constraint_name
        self.name.sub(/^.*::/, '').sub(/Validator$/, '').underscore
      end
    end

    def validate(value)
      true
    end

    # Convert this validator to a Hash using the given +format+.
    def to_h(format = :org3)
      case format
      when :org3
        to_h_org3
      else
        raise ArgumentError, "unknown format '#{format}'"
      end
    end

    private

    # Called when {#to_h} is called with +:org3+ format.
    # Sub-classes are supposed to overwrite this methods and to return
    # their conversion to the json schema standard draft v3.
    def to_h_org3
      raise NoMethodError, "overwrite me in sub-classes"
    end
  end
end
