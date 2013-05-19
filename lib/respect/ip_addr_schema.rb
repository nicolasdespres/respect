require 'ipaddr'

module Respect
  # Validate a string containing an IPv4 or IPv6 address but also accept IPAddr object.
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
