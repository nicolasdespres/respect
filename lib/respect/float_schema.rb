module Respect
  class FloatSchema < NumericSchema

    def validate_type(object)
      case object
      when String
        if object =~ /^[-+]?\d+(\.\d+)?$/
          object.to_f
        else
          raise ValidationError,
                "malformed float value: `#{object}'"
        end
      when Float
        object
      else
        raise ValidationError, "object is not a float but a '#{object.class}'"
      end
    end

  end # class FloatSchema
end # module Respect
