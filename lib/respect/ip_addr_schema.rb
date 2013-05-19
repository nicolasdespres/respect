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
      when IPAddr
        object
      else
        FormatValidator.new(:ip_addr).validate(object)
      end
    end

  end # class IPAddrSchema
end # module Respect
