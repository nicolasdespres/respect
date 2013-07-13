module Respect
  class MatchValidator < Validator
    def initialize(pattern)
      @pattern = pattern
    end

    def validate(value)
      unless value =~ @pattern
        raise ValidationError, "#{value.inspect} does not match #{@pattern.inspect}"
      end
    end

    # Overwritten method. See {Validator#explain}.
    def explain
      "Must match #{@pattern.inspect}."
    end

    private

    def to_h_org3
      { "pattern" => @pattern.source }
    end
  end
end
