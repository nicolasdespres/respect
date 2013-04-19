module Respect
  class Ipv4AddrSchema < StringSchema

    def validate_format(doc)
      FormatValidator.new.validate_ipv4_addr(doc)
    end

  end # class Ipv4AddrSchema
end # module Respect
