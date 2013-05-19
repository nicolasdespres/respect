require "test_helper"

class Ipv4AddrSchemaTest < Test::Unit::TestCase

  def test_ipv4_addr_schema_creates_ipaddr_object
    s = Respect::Ipv4AddrSchema.new
    assert_nil s.sanitized_object
    assert_schema_validate s, "192.168.0.2"
    assert s.sanitized_object.is_a?(IPAddr)
    assert s.sanitized_object.ipv4?
    assert_equal("192.168.0.2", s.sanitized_object.to_s)
  end

  def test_ipv4_addr_schema_relies_on_format_validator
    doc = "192.168.0.2"
    Respect::FormatValidator.any_instance.stubs(:validate_ipv4_addr).with(doc).at_least_once
    Respect::Ipv4AddrSchema.new.validate(doc)
  end

  def test_failed_validation_reset_sanitized_object
    s = Respect::Ipv4AddrSchema.new
    assert_schema_validate(s, "192.168.0.2")
    assert_not_nil(s.sanitized_object)
    assert_schema_invalidate(s, "wrong")
    assert_nil(s.sanitized_object)
  end
end
