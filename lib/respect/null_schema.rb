module Respect
  class NullSchema < Schema

    public_class_method :new

    def validate(doc)
      case doc
      when String
        if doc == "null"
          self.sanitized_object = nil
          true
        else
          raise ValidationError,
                "expected 'null' value but got '#{doc}:#{doc.class}'"
        end
      when NilClass
        self.sanitized_object = nil
        true
      else
        raise ValidationError,
              "document is not of null type but a #{doc.class}"
      end
    end

  end # class NullSchema
end # module Respect
