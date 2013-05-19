module Respect
  class IPAddrSchema < StringSchema

    def validate_type(object)
      case object
      when NilClass
        if allow_nil?
          nil
        else
          raise ValidationError, "object is nil but this #{self.class} does not allow nil"
        end
      else
        FormatValidator.new(:ip_addr).validate(object)
      end
    end

  end # class IPAddrSchema
end # module Respect
