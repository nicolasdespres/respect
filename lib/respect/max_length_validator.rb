module Respect
  class MaxLengthValidator
    def initialize(max_length)
      @max_length = max_length
    end

    def validate(value)
      unless value.length <= @max_length
        raise ValidationError,
              "#{value.inspect} must be at most #@max_length long but is #{value.length}"
      end
    end
  end
end
