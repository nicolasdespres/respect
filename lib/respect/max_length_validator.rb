module Respect
  class MaxLengthValidator
    def validate(value, max_length)
      unless value.length <= max_length
        raise ValidationError,
              "#{value.inspect} must be at most #{max_length} long but is #{value.length}"
      end
    end
  end
end
