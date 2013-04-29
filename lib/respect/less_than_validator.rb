module Respect
  class LessThanValidator < Validator
    def initialize(max)
      @max = max
    end

    def validate(value)
      unless value < @max
        raise ValidationError, "#{value} is not less than #@max"
      end
    end

    private

    def to_h_org3
      { "maximum" => @max, "exclusiveMaximum" => true }
    end
  end
end
