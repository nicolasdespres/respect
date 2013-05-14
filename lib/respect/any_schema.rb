module Respect
  class AnySchema < Schema

    public_class_method :new

    def validate(doc)
      case doc
      when Hash, Array, TrueClass, FalseClass, Numeric, NilClass, String
        self.sanitized_object = doc
        true
      else
        raise ValidationError,
              "document is not of a valid type but a #{doc.class}"
      end
    end

  end # class AnySchema
end # module Respect
