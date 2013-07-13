module Respect
  class LessThanOrEqualToValidator < Validator
    def initialize(max)
      @max = max
    end

    def validate(value)
      unless value <= @max
        raise ValidationError, "#{value} is not less than or equal to #@max"
      end
    end

    # Overwritten method. See {Validator#explain}.
    def explain
      "Must be less than or equal to #@max."
    end

    private

    def to_h_org3
      { "maximum" => @max }
    end
  end
end
