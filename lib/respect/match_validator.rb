module Respect
  class MatchValidator < Validator
    def validate(value, pattern)
      unless value =~ pattern
        raise ValidationError, "#{value.inspect} does not match #{pattern.inspect}"
      end
    end
  end
end
