module Respect
  class MatchValidator < Validator
    def initialize(pattern)
      @pattern = pattern
    end

    def validate(value)
      unless value =~ @pattern
        raise ValidationError, "#{value.inspect} does not match #{@pattern.inspect}"
      end
    end
  end
end
