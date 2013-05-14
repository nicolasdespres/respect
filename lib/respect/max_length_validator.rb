module Respect
  class MaxLengthValidator < Validator
    def initialize(max_length)
      @max_length = max_length
    end

    def validate(value)
      unless value.length <= @max_length
        raise ValidationError,
              "#{value.inspect} must be at most #@max_length long but is #{value.length}"
      end
    end

    private

    def to_h_org3
      { 'maxLength' => @max_length }
    end
  end
end
