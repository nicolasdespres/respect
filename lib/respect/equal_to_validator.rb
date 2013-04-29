module Respect
  class EqualToValidator < Validator
    def initialize(expected)
      @expected = expected
    end

    def validate(value)
      unless value == @expected
        raise ValidationError,
              "wrong value: `#{value}':#{value.class} instead of `#@expected':#{@expected.class}"
      end
    end
  end
end
