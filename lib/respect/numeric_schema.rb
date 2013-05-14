module Respect
  class NumericSchema < Schema
    include HasConstraints

    public_class_method :new

    def validate_type(object)
      case object
      when String
        if match_data = /^[-+]?\d+(\.\d+)?$/.match(object)
          if match_data[1]
            object.to_f
          else
            object.to_i
          end
        else
          raise ValidationError, "malformed numeric value: `#{object}'"
        end
      when Integer, Float
        object
      else
        raise ValidationError, "object is not a numeric but a '#{object.class}'"
      end
    end

  end # class NumericSchema
end # module Respect
