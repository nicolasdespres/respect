module Respect
  class IPAddrSchema < StringSchema

    def validate_type(object)
      FormatValidator.new(:ip_addr).validate(object)
    end

  end # class IPAddrSchema
end # module Respect
