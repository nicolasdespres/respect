module Respect
  class GreaterThanValidator < Validator
    def initialize(min)
      @min = min
    end

    def validate(value)
      unless value > @min
        raise ValidationError, "#{value} is not greater than #@min"
      end
    end

    # Overwritten method. See {Validator#explain}.
    def explain
      "Must be greater than #@min."
    end

    private

    def to_h_org3
      { "minimum" => @min, "exclusiveMinimum" => true }
    end
  end
end
