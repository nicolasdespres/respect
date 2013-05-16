require "test_helper"

class DatetimeSchemaTest < Test::Unit::TestCase

  def test_datetime_schema_creates_datetime_object
    s = Respect::DatetimeSchema.new
    assert_nil s.sanitized_object
    assert_schema_validate s, "2013-12-01T00:00:00+00:00"
    assert s.sanitized_object.is_a?(DateTime)
    assert_equal DateTime.rfc3339("2013-12-01T00:00:00+00:00"), s.sanitized_object
  end

  def test_datetime_schema_relies_on_format_validator
    doc = "2013-12-01T00:00:00+00:00"
    Respect::FormatValidator.any_instance.stubs(:validate_datetime).with(doc).at_least_once
    Respect::DatetimeSchema.new.validate(doc)
  end

end
