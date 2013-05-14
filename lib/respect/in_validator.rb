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

    private

    def to_h_org3
      { 'enum' => @set.dup }
    end
  end
end
