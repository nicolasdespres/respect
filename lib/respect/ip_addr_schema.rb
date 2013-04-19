module Respect
  class IpAddrSchema < StringSchema

    def validate_format(doc)
      FormatValidator.new.validate_ip_addr(doc)
    end

  end # class IpAddrSchema
end # module Respect
