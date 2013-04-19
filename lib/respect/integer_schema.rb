module Respect
  class IntegerSchema < NumericSchema

    def validate_format(doc)
      case doc
      when String
        if doc =~ /^[-+]?\d+$/
          doc.to_i
        else
          raise ValidationError,
                "malformed integer value: `#{doc}'"
        end
      when Integer
        doc
      else
        raise ValidationError, "document is not an integer but a '#{doc.class}'"
      end
    end

  end # class IntegerSchema
end
