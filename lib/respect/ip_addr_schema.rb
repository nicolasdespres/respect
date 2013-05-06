module Respect
  class IPAddrSchema < StringSchema

    def validate_type(doc)
      FormatValidator.new(:ip_addr).validate(doc)
    end

  end # class IPAddrSchema
end # module Respect
