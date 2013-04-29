module Respect
  class Validator

    class << self
      # Turn this validator class name into a constraint name.
      def constraint_name
        self.name.sub(/^.*::/, '').sub(/Validator$/, '').underscore
      end
    end

    def validate(value, arg)
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
