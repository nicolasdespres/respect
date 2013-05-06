module Respect
  class NumericSchema < Schema
    include HasConstraints

    public_class_method :new

    def validate_type(doc)
      case doc
      when String
        if match_data = /^[-+]?\d+(\.\d+)?$/.match(doc)
          if match_data[1]
            doc.to_f
          else
            doc.to_i
          end
        else
          raise ValidationError, "malformed numeric value: `#{doc}'"
        end
      when Integer, Float
        doc
      else
        raise ValidationError, "document is not a numeric but a '#{doc.class}'"
      end
    end

  end # class NumericSchema
end # module Respect
