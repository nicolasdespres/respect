module Respect
  class BooleanSchema < Schema
    include HasConstraints

    public_class_method :new

    def validate_type(doc)
      case doc
      when String
        if doc == "true"
          true
        elsif doc == "false"
          false
        else
          raise ValidationError,
                "malformed boolean value: `#{doc}'"
        end
      when TrueClass, FalseClass
        doc
      else
        raise ValidationError, "document is not a boolean but a '#{doc.class}'"
      end
    end

  end # class BooleanSchema
end # module Respect
