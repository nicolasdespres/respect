require 'uri'

module Respect
  # Validate a string containing an URI but also accepts URI object.
  class URISchema < StringSchema

    def validate_type(object)
      case object
      when NilClass
        if allow_nil?
          nil
        else
          raise ValidationError, "object is nil but this #{self.class} does not allow nil"
        end
      when URI
        object
      else
        FormatValidator.new(:uri).validate(object)
      end
    end

  end # class URISchema
end # module Respect
