module Respect
  # A UTC time. It creates a Time object.
  class UTCTimeSchema < NumericSchema

    def validate_type(object)
      value = super
      if value < 0
        raise ValidationError,
              "UTC time value #{value} cannot be negative"
      end
      Time.at(value)
    end

  end # class UTCTimeSchema
end # module Respect
