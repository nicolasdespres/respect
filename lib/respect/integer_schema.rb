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
      when NilClass
        if allow_nil?
          nil
        else
          raise ValidationError, "object is nil but this #{self.class} does not allow nil"
        end
      else
        raise ValidationError, "object is not an integer but a '#{object.class}'"
      end
    end

  end # class IntegerSchema
end
