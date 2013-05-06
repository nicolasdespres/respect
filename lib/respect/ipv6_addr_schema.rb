module Respect
  class Ipv6AddrSchema < StringSchema

    def validate_type(doc)
      FormatValidator.new(:ipv6_addr).validate(doc)
    end

  end # class Ipv6AddrSchema
end # module Respect
