module Respect
  class MinLengthValidator
    def initialize(min_length)
      @min_length = min_length
    end

    def validate(value)
      unless value.length >= @min_length
        raise ValidationError,
              "#{value.inspect} must be at least #@min_length long but is #{value.length}"
      end
    end
  end
end
