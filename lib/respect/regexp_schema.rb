module Respect
  # Validate a string containing a regexp but also accept Regexp object.
  class RegexpSchema < StringSchema

    def validate_type(object)
      case object
      when NilClass
        if allow_nil?
          nil
        else
          raise ValidationError, "object is nil but this #{self.class} does not allow nil"
        end
      else
        FormatValidator.new(:regexp).validate(object)
      end
    end

  end # class RegexpSchema
end # module Respect
