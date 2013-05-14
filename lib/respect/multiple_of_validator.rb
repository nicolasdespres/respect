module Respect
  class MultipleOfValidator < DivisibleByValidator
    def validate(value)
      super
    rescue ValidationError => e
      raise ValidationError,
            e.message.sub(/\bdivisible by\b/, "a multiple of")
    end
  end
end # module Respect
