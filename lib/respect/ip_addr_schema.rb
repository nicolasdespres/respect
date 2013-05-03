module Respect
  class IPAddrSchema < StringSchema

    def validate_format(doc)
      FormatValidator.new(:ip_addr).validate(doc)
    end

  end # class IPAddrSchema
end # module Respect
