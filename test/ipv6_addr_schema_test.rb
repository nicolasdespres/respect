require "test_helper"

class Ipv6AddrSchemaTest < Test::Unit::TestCase

  def test_ipv6_addr_schema_creates_ipaddr_object
    s = Respect::Ipv6AddrSchema.new
    assert_nil s.sanitized_object
    assert_schema_validate s, "3ffe:505:2::1"
    assert s.sanitized_object.is_a?(IPAddr)
    assert s.sanitized_object.ipv6?
    assert_equal("3ffe:505:2::1", s.sanitized_object.to_s)
  end

  def test_ipv6_addr_schema_relies_on_format_validator
    doc = "3ffe:505:2::1"
    Respect::FormatValidator.any_instance.stubs(:validate_ipv6_addr).with(doc).at_least_once
    Respect::Ipv6AddrSchema.new.validate(doc)
  end

  def test_failed_validation_reset_sanitized_object
    s = Respect::Ipv6AddrSchema.new
    assert_schema_validate(s, "3ffe:505:2::1")
    assert_not_nil(s.sanitized_object)
    assert_schema_invalidate(s, "wrong")
    assert_nil(s.sanitized_object)
  end

  def test_allow_nil
    s = Respect::Ipv6AddrSchema.new(allow_nil: true)
    assert s.allow_nil?
    assert_schema_validate s, nil
    assert_equal(nil, s.sanitized_object)
    assert_schema_validate s, "3ffe:505:2::1"
    assert_not_nil(s.sanitized_object)
    assert_schema_invalidate(s, "wrong")
    assert_nil(s.sanitized_object)
  end

  def test_disallow_nil
    s = Respect::Ipv6AddrSchema.new
    assert !s.allow_nil?
    exception = assert_exception(Respect::ValidationError) { s.validate(nil) }
    assert_match exception.message, /\bIpv6AddrSchema\b/
    assert_equal(nil, s.sanitized_object)
    assert_schema_validate s, "3ffe:505:2::1"
    assert_not_nil(s.sanitized_object)
    assert_schema_invalidate(s, "wrong")
    assert_nil(s.sanitized_object)
  end
end
