module Respect
  class StringSchema < Schema
    include HasConstraints

    public_class_method :new

    def validate_type(object)
      case object
      when NilClass
        if allow_nil?
          nil
        else
          raise ValidationError, "object is nil but this #{self.class} does not allow nil"
        end
      else
        object.to_s
      end
    end

  end
end
