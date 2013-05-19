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
      else
        FormatValidator.new(:ipv6_addr).validate(object)
      end
    end

  end # class Ipv6AddrSchema
end # module Respect
