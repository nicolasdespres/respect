module Respect
  class Ipv6AddrSchema < StringSchema

    def validate_format(doc)
      FormatValidator.new(:ipv6_addr).validate(doc)
    end

  end # class Ipv6AddrSchema
end # module Respect
