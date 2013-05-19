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

  def test_datetime_schema_validate_iso8601
    t = Time.now.to_datetime
    s = Respect::DatetimeSchema.new
    assert_schema_validate(s, t.iso8601)
    assert_equal t.to_time.to_i, s.sanitized_object.to_time.to_i
  end

  def test_failed_validation_reset_sanitized_object
    s = Respect::DatetimeSchema.new
    assert_schema_validate(s, "2013-12-01T00:00:00+00:00")
    assert_not_nil(s.sanitized_object)
    assert_schema_invalidate(s, "wrong")
    assert_nil(s.sanitized_object)
  end

  def test_allow_nil
    s = Respect::DatetimeSchema.new(allow_nil: true)
    assert s.allow_nil?
    assert_schema_validate s, nil
    assert_equal(nil, s.sanitized_object)
    assert_schema_validate s, "2013-12-01T00:00:00+00:00"
    assert_not_nil(s.sanitized_object)
    assert_schema_invalidate(s, "wrong")
    assert_nil(s.sanitized_object)
  end

  def test_disallow_nil
    s = Respect::DatetimeSchema.new
    assert !s.allow_nil?
    exception = assert_exception(Respect::ValidationError) { s.validate(nil) }
    assert_match exception.message, /\bDatetimeSchema\b/
    assert_equal(nil, s.sanitized_object)
    assert_schema_validate s, "2013-12-01T00:00:00+00:00"
    assert_not_nil(s.sanitized_object)
    assert_schema_invalidate(s, "wrong")
    assert_nil(s.sanitized_object)
  end

  def test_validate_datetime_object
    s = Respect::DatetimeSchema.new
    t = Time.now.to_datetime
    assert_equal(DateTime, t.class)
    assert_schema_validate s, t
    assert_equal DateTime, s.sanitized_object.class
    assert_equal t, s.sanitized_object
  end

  def test_validate_time_object
    s = Respect::DatetimeSchema.new
    t = Time.now
    assert_equal(Time, t.class)
    assert_schema_validate s, t
    assert_equal DateTime, s.sanitized_object.class
    assert_equal t.to_datetime, s.sanitized_object
  end
  end
end
