require "test_helper"

class Ipv4AddrSchemaTest < Test::Unit::TestCase

  def test_ipv4_addr_schema_creates_ipaddr_object
    s = Respect::Ipv4AddrSchema.new
    assert_nil s.sanitized_doc
    assert s.validate?("192.168.0.2")
    assert s.sanitized_doc.is_a?(IPAddr)
    assert s.sanitized_doc.ipv4?
    assert_equal("192.168.0.2", s.sanitized_doc.to_s)
  end

  def test_ipv4_addr_schema_relies_on_format_validator
    doc = "192.168.0.2"
    Respect::FormatValidator.any_instance.stubs(:validate_ipv4_addr).with(doc).at_least_once
    Respect::Ipv4AddrSchema.new.validate(doc)
  end

end
