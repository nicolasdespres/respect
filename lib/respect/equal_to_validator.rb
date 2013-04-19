module Respect
  class EqualToValidator < Validator
    def validate(value, expected)
      unless value == expected
        raise ValidationError,
              "wrong value: `#{value}':#{value.class} instead of `#{expected}':#{expected.class}"
      end
    end
  end
end
