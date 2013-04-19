module Respect
  class LessThanOrEqualToValidator < Validator
    def validate(value, max)
      unless value <= max
        raise ValidationError, "#{value} is not less than or equal to #{max}"
      end
    end
  end
end
