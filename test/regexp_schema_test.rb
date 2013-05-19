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

  def test_failed_validation_reset_sanitized_object
    s = Respect::RegexpSchema.new
    assert_schema_validate(s, "a*b*")
    assert_not_nil(s.sanitized_object)
    assert_schema_invalidate(s, "*")
    assert_nil(s.sanitized_object)
  end

  def test_allow_nil
    s = Respect::RegexpSchema.new(allow_nil: true)
    assert s.allow_nil?
    assert_schema_validate s, nil
    assert_equal(nil, s.sanitized_object)
    assert_schema_validate s, "a*b*"
    assert_not_nil(s.sanitized_object)
    assert_schema_invalidate(s, "*")
    assert_nil(s.sanitized_object)
  end

  def test_disallow_nil
    s = Respect::RegexpSchema.new
    assert !s.allow_nil?
    exception = assert_exception(Respect::ValidationError) { s.validate(nil) }
    assert_match exception.message, /\bRegexpSchema\b/
    assert_equal(nil, s.sanitized_object)
    assert_schema_validate s, "a*b*"
    assert_not_nil(s.sanitized_object)
    assert_schema_invalidate(s, "*")
    assert_nil(s.sanitized_object)
  end
end
