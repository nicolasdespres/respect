module Respect
  # A UTC time. It creates a Time object.
  class UtcTimeSchema < NumericSchema

    def validate_format(doc)
      value = super
      if value < 0
        raise ValidationError,
              "UTC time value #{value} cannot be negative"
      end
      Time.at(value)
    end

  end # class UtcTimeSchema
end # module Respect
