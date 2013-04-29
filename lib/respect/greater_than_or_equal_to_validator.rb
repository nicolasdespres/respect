module Respect
  class GreaterThanOrEqualToValidator
    def initialize(min)
      @min = min
    end

    def validate(value)
      unless value >= @min
        raise ValidationError, "#{value} is not greater than or equal to #@min"
      end
    end
  end
end
