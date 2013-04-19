module Respect
  class GreaterThanOrEqualToValidator
    def validate(value, min)
      unless value >= min
        raise ValidationError, "#{value} is not greater than or equal to #{min}"
      end
    end
  end
end
