module Respect
  class Ipv6AddrSchema < StringSchema

    def validate_format(doc)
      FormatValidator.new.validate_ipv6_addr(doc)
    end

  end # class Ipv6AddrSchema
end # module Respect
