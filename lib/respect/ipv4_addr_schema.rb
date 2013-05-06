module Respect
  class Ipv4AddrSchema < StringSchema

    def validate_type(doc)
      FormatValidator.new(:ipv4_addr).validate(doc)
    end

  end # class Ipv4AddrSchema
end # module Respect
