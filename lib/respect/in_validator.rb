module Respect
  class InValidator < Validator
    def validate(value, set)
      unless set.include?(value)
        raise ValidationError, "#{value.inspect} is not included in #{set}"
      end
    end
  end
end
