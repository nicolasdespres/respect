module Respect
  class GreaterThanValidator < Validator
    def validate(value, min)
      unless value > min
        raise ValidationError, "#{value} is not greater than #{min}"
      end
    end
  end
end
