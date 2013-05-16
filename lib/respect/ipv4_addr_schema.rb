module Respect
  class Ipv4AddrSchema < StringSchema

    def validate_type(object)
      FormatValidator.new(:ipv4_addr).validate(object)
    end

  end # class Ipv4AddrSchema
end # module Respect
