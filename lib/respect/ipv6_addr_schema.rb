module Respect
  class Ipv6AddrSchema < StringSchema

    def validate_type(object)
      FormatValidator.new(:ipv6_addr).validate(object)
    end

  end # class Ipv6AddrSchema
end # module Respect
