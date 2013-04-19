module Respect
  class DivisibleByValidator < Validator
    def validate(value, divider)
      unless (value % divider).zero?
        raise ValidationError, "#{value} is not divisible by #{divider}"
      end
    end
  end
end
