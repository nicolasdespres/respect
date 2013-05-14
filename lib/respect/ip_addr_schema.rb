module Respect
  class IpAddrSchema < StringSchema

    def validate_format(doc)
      FormatValidator.new(:ip_addr).validate(doc)
    end

  end # class IpAddrSchema
end # module Respect
