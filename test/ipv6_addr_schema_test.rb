require "test_helper"

class Ipv6AddrSchemaTest < Test::Unit::TestCase

  def test_ipv6_addr_schema_creates_ipaddr_object
    s = Respect::Ipv6AddrSchema.new
    assert_nil s.sanitized_doc
    assert s.validate?("3ffe:505:2::1")
    assert s.sanitized_doc.is_a?(IPAddr)
    assert s.sanitized_doc.ipv6?
    assert_equal("3ffe:505:2::1", s.sanitized_doc.to_s)
  end

  def test_ipv6_addr_schema_relies_on_format_validator
    doc = "3ffe:505:2::1"
    Respect::FormatValidator.any_instance.stubs(:validate_ipv6_addr).with(doc).at_least_once
    Respect::Ipv6AddrSchema.new.validate(doc)
  end

end
