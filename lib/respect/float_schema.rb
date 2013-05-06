module Respect
  class FloatSchema < NumericSchema

    def validate_type(doc)
      case doc
      when String
        if doc =~ /^[-+]?\d+(\.\d+)?$/
          doc.to_f
        else
          raise ValidationError,
                "malformed float value: `#{doc}'"
        end
      when Float
        doc
      else
        raise ValidationError, "document is not a float but a '#{doc.class}'"
      end
    end

  end # class FloatSchema
end # module Respect
