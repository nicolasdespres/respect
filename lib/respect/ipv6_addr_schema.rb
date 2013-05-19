require 'ipaddr'

module Respect
  class Ipv6AddrSchema < StringSchema

    def validate_type(object)
      case object
      when NilClass
        if allow_nil?
          nil
        else
          raise ValidationError, "object is nil but this #{self.class} does not allow nil"
        end
      when IPAddr
        if object.ipv6?
          object
        else
          raise ValidationError, "IPAddr object '#{object}' is not IPv6"
        end
      else
        FormatValidator.new(:ipv6_addr).validate(object)
      end
    end

  end # class Ipv6AddrSchema
end # module Respect
