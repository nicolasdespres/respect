require "test_helper"

class StringSchemaTest < Test::Unit::TestCase
  def test_expected_value_are_not_converted
    s = Respect::StringSchema.new(equal_to: 42)
    assert_raise(Respect::ValidationError) do
      assert s.validate("42")
    end
  end

  def test_non_string_value_get_converted
    s = Respect::StringSchema.new
    assert_equal "42", s.validate_type(42)
    assert_nil s.sanitized_doc
    s.validate(42)
    assert_equal "42", s.sanitized_doc
  end

  def test_string_property_has_no_greater_than_constraint
    s = Respect::StringSchema.new(greater_than: 0)
    # Using an integer constraints with a string lead to
    # unexpected result.
    assert_raises(ArgumentError) do
      s.validate(-1)
    end
  end

  def test_string_accept_options_mixed_with_constraints
    s = Respect::StringSchema.new(equal_to: "42", required: false)
    assert_equal false, s.options[:required]
    assert_equal "42", s.options[:equal_to]
    assert s.validate("42")
  end

  def test_string_value_is_in_set
    s = Respect::StringSchema.new(in: ["foo", "bar"])
    assert_schema_validate s, "foo"
    assert_schema_validate s, "bar"
    assert_schema_invalidate s, "not included"
  end

  def test_string_value_match_pattern
    s = Respect::StringSchema.new(match: /foo*/)
    assert_schema_validate s, "_foo_"
    assert_schema_validate s, "fo"
    assert_schema_validate s, "fol"
    assert_schema_validate s, "foooooooooooo"
    assert_schema_invalidate s, "f_b"
  end

  def test_string_value_has_min_length
    s = Respect::StringSchema.new(min_length: 2)
    assert_schema_validate s, "foo"
    assert_schema_validate s, "fo"
    assert_schema_invalidate s, "f"
  end

  def test_string_value_has_max_length
    s = Respect::StringSchema.new(max_length: 2)
    assert_schema_invalidate s, "foo"
    assert_schema_validate s, "fo"
    assert_schema_validate s, "f"
  end

  def test_string_accept_equal_to_constraint
    s = Respect::StringSchema.new(equal_to: "41")
    assert_schema_validate s, "41"
    assert_schema_invalidate s, "52"
  end

  def test_string_validate_email_format
    [
      [ "foo",            false, ],
      [ "foo@bar",        true,  ],
      [ "foo@example.om", true,  ],
    ].each_with_index do |data, i|
      assert_validate_string_format(:email, data[1], data[0])
    end
  end

  def test_string_validate_uri_format
    [
      [ "<>",             false, ],
      [ "http://foo.com", true,  ],
      [ "foo@example.om", true,  ],
    ].each_with_index do |data, i|
      assert_validate_string_format(:uri, data[1], data[0])
    end
  end

  def test_string_validate_regexp_format
    [
      [ "foo(",      false, ],
      [ "^foo$",     true,  ],
      [ "^foo|bar$", true,  ],
    ].each_with_index do |data, i|
      assert_validate_string_format(:regexp, data[1], data[0])
    end
  end

  def test_string_validate_datetime_format
    [
      [ "invalid",                   false, ],
      [ "2013-12-01T00:00:00+00:00", true,  ],
    ].each_with_index do |data, i|
      assert_validate_string_format(:datetime, data[1], data[0])
    end
  end

  def test_string_validate_ipv4_addr_format
    [
      [ "192.168.0.1", true, ],
      [ "invalid",     false, ],
    ].each_with_index do |data, i|
      assert_validate_string_format(:ipv4_addr, data[1], data[0])
    end
  end

  def test_string_validate_phone_number_format
    [
      [ "+3360123456789", true, ],
      [ "invalid",        false, ],
    ].each_with_index do |data, i|
      assert_validate_string_format(:phone_number, data[1], data[0])
    end
  end

  def test_string_validate_ipv6_addr_format
    [
      [ "3ffe:505:2::1", true, ],
      [ "invalid",        false, ],
    ].each_with_index do |data, i|
      assert_validate_string_format(:ipv6_addr, data[1], data[0])
    end
  end

  def test_string_validate_ip_addr_format
    [
      [ "192.168.0.1",   true, ],
      [ "3ffe:505:2::1", true, ],
      [ "invalid",       false, ],
    ].each_with_index do |data, i|
      assert_validate_string_format(:ip_addr, data[1], data[0])
    end
  end

  def test_string_validate_hostname_format
    [
      [ "a.b.c.d",  true, ],
      [ "0invalid", false, ],
    ].each_with_index do |data, i|
      assert_validate_string_format(:hostname, data[1], data[0])
    end
  end

  private

  def assert_validate_string_format(format, result, doc)
    s = Respect::StringSchema.new(format: format)
    assert_nil s.sanitized_doc
    assert_schema_validation_is result, s, doc, "validate '#{doc}'"
    if result
      assert s.sanitized_doc.is_a?(String), "is a String for '#{doc}'"
      assert_equal doc, s.sanitized_doc, "sanitize '#{doc}'"
    else
      assert_nil s.sanitized_doc
    end
  end
end
