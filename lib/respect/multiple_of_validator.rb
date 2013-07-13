module Respect
  class MultipleOfValidator < Validator
    def initialize(multiplier)
      @validator = DivisibleByValidator.new(multiplier)
    end

    def validate(value)
      begin
        @validator.validate(value)
      rescue ValidationError => e
        raise ValidationError,
              e.message.sub(/\bdivisible by\b/, "a multiple of")
      end
    end

    private

    def to_h_org3
      @validator.send(:to_h_org3)
    end

    # Overwritten method. See {Validator#explain}.
    def explain
      "Must be a multiple of #@divider."
    end

  end
end # module Respect
