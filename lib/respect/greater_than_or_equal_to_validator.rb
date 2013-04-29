module Respect
  class GreaterThanOrEqualToValidator < Validator
    def initialize(min)
      @min = min
    end

    def validate(value)
      unless value >= @min
        raise ValidationError, "#{value} is not greater than or equal to #@min"
      end
    end

    private

    def to_h_org3
      { "minimum" => @min }
    end
  end
end
