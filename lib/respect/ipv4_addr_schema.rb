module Respect
  class Ipv4AddrSchema < StringSchema

    def validate_format(doc)
      FormatValidator.new(:ipv4_addr).validate(doc)
    end

  end # class Ipv4AddrSchema
end # module Respect
