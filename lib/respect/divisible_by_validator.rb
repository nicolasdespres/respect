module Respect
  class DivisibleByValidator < Validator
    def initialize(divider)
      @divider = divider
    end

    def validate(value)
      unless (value % @divider).zero?
        raise ValidationError, "#{value} is not divisible by #@divider"
      end
    end
  end
end
