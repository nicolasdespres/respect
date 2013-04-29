module Respect
  class InValidator < Validator
    def initialize(set)
      @set = set
    end

    def validate(value)
      unless @set.include?(value)
        raise ValidationError, "#{value.inspect} is not included in #@set"
      end
    end
  end
end
