require 'ipaddr'

module Respect
  # Validate a string containing an IPv4 address but also accept IPAddr object.
  class Ipv4AddrSchema < StringSchema

    def validate_type(object)
      case object
      when NilClass
        if allow_nil?
          nil
        else
          raise ValidationError, "object is nil but this #{self.class} does not allow nil"
        end
      when IPAddr
        if object.ipv4?
          object
        else
          raise ValidationError, "IPAddr object '#{object}' is not IPv4"
        end
      else
        FormatValidator.new(:ipv4_addr).validate(object)
      end
    end

  end # class Ipv4AddrSchema
end # module Respect
