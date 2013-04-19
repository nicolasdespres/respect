module Respect
  class MinLengthValidator
    def validate(value, min_length)
      unless value.length >= min_length
        raise ValidationError,
              "#{value.inspect} must be at least #{min_length} long but is #{value.length}"
      end
    end
  end
end
