module Respect
  class BooleanSchema < Schema
    include HasConstraints

    public_class_method :new

    def validate_type(object)
      case object
      when String
        if object == "true"
          true
        elsif object == "false"
          false
        else
          raise ValidationError,
                "malformed boolean value: `#{object}'"
        end
      when TrueClass, FalseClass
        object
      when NilClass
        if allow_nil?
          nil
        else
          raise ValidationError, "object is nil but this #{self.class} does not allow nil"
        end
      else
        raise ValidationError, "object is not a boolean but a '#{object.class}'"
      end
    end

  end # class BooleanSchema
end # module Respect
