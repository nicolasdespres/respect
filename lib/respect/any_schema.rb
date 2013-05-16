module Respect
  class AnySchema < Schema

    public_class_method :new

    def validate(object)
      case object
      when Hash, Array, TrueClass, FalseClass, Numeric, NilClass, String
        self.sanitized_object = object
        true
      else
        raise ValidationError,
              "object is not of a valid type but a #{object.class}"
      end
    end

  end # class AnySchema
end # module Respect
