module Respect
  class LessThanValidator < Validator
    def validate(value, max)
      unless value < max
        raise ValidationError, "#{value} is not less than #{max}"
      end
    end
  end
end
