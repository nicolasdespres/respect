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
  end
end
