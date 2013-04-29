module Respect
  # Test class proving that users can easily extend the validator hierarchy
  # with their own ones.
  class UniversalValidator < Validator

    def initialize(enabled)
      @enabled = enabled
    end

    def validate(value)
      if @enabled
        unless value == 42
          raise ValidationError, "#{value} is not a universal value"
        end
      end
    end

    private

    def to_h_org3
      { "minimum" => 42, "maximum" => 42 }
    end

  end # class UniversalValidator
end # module Respect
