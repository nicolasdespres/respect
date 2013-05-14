module Respect
  class IntegerSchema < NumericSchema

    def validate_type(object)
      case object
      when String
        if object =~ /^[-+]?\d+$/
          object.to_i
        else
          raise ValidationError,
                "malformed integer value: `#{object}'"
        end
      when Integer
        object
      else
        raise ValidationError, "object is not an integer but a '#{object.class}'"
      end
    end

  end # class IntegerSchema
end
