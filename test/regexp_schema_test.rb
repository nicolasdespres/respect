require "test_helper"

class RegexpSchemaTest < Test::Unit::TestCase

  def test_regexp_schema_creates_uri_object
    s = Respect::RegexpSchema.new
    assert_nil s.sanitized_object
    assert_schema_validate s, "a*b*"
    assert s.sanitized_object.is_a?(Regexp)
    assert_equal(/a*b*/, s.sanitized_object)
  end

  def test_regexp_schema_relies_on_format_validator
    doc = "a*b*"
    Respect::FormatValidator.any_instance.stubs(:validate_regexp).with(doc).at_least_once
    Respect::RegexpSchema.new.validate(doc)
  end

end
