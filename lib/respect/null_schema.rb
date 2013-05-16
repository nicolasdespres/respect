module Respect
  class NullSchema < Schema

    public_class_method :new

    def validate(object)
      case object
      when String
        if object == "null"
          self.sanitized_object = nil
          true
        else
          raise ValidationError,
                "expected 'null' value but got '#{object}:#{object.class}'"
        end
      when NilClass
        self.sanitized_object = nil
        true
      else
        raise ValidationError,
              "object is not of null type but a #{object.class}"
      end
    end

  end # class NullSchema
end # module Respect
