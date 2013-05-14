require "test_helper"

class IPAddrSchemaTest < Test::Unit::TestCase

  def test_ip_addr_schema_creates_ipaddr_object
    s = Respect::IPAddrSchema.new
    assert_nil s.sanitized_object
    # IPv4
    assert_schema_validate s, "192.168.0.2"
    assert s.sanitized_object.is_a?(IPAddr)
    assert s.sanitized_object.ipv4?
    assert_equal("192.168.0.2", s.sanitized_object.to_s)
    # IPv6
    assert_schema_validate s, "3ffe:505:2::1"
    assert s.sanitized_object.is_a?(IPAddr)
    assert s.sanitized_object.ipv6?
    assert_equal("3ffe:505:2::1", s.sanitized_object.to_s)
  end

  def test_ip_addr_schema_relies_on_format_validator
    doc = "192.168.0.2"
    Respect::FormatValidator.any_instance.stubs(:validate_ip_addr).with(doc).at_least_once
    Respect::IPAddrSchema.new.validate(doc)
  end

end
