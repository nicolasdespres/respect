require "test_helper"

class IpAddrSchemaTest < Test::Unit::TestCase

  def test_ip_addr_schema_creates_ipaddr_object
    s = Respect::IpAddrSchema.new
    assert_nil s.sanitized_doc
    # IPv4
    assert s.validate?("192.168.0.2")
    assert s.sanitized_doc.is_a?(IPAddr)
    assert s.sanitized_doc.ipv4?
    assert_equal("192.168.0.2", s.sanitized_doc.to_s)
    # IPv6
    assert s.validate?("3ffe:505:2::1")
    assert s.sanitized_doc.is_a?(IPAddr)
    assert s.sanitized_doc.ipv6?
    assert_equal("3ffe:505:2::1", s.sanitized_doc.to_s)
  end

  def test_ip_addr_schema_relies_on_format_validator
    doc = "192.168.0.2"
    Respect::FormatValidator.any_instance.stubs(:validate_ip_addr).with(doc).at_least_once
    Respect::IpAddrSchema.new.validate(doc)
  end

end
