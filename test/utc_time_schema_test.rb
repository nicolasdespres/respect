require "test_helper"

class UTCTimeSchemaTest < Test::Unit::TestCase

  def test_utc_time_schema_creates_time_object
    s = Respect::UTCTimeSchema.new
    assert_nil s.sanitized_object
    t = Time.now.to_i
    assert_schema_validate s, t.to_s
    assert_equal Time, s.sanitized_object.class
    assert_equal(t, s.sanitized_object.to_i)
  end

  def test_utc_time_schema_accept_float
    s = Respect::UTCTimeSchema.new
    assert_nil s.sanitized_object
    t = Time.now.to_f
    assert_schema_validate s, t.to_s
    assert_equal Time, s.sanitized_object.class
    assert_equal(t, s.sanitized_object.to_f)
  end

  def test_utc_time_schema_do_not_accept_negative
    s = Respect::UTCTimeSchema.new
    begin
      s.validate(-1)
      assert false
    rescue Respect::ValidationError => e
      assert_match(/-1/, e.message)
    end
  end

  def test_failed_validation_reset_sanitized_object
    s = Respect::UTCTimeSchema.new
    assert_schema_validate(s, 42)
    assert_not_nil(s.sanitized_object)
    assert_schema_invalidate(s, "*")
    assert_nil(s.sanitized_object)
  end

  def test_allow_nil
    s = Respect::UTCTimeSchema.new(allow_nil: true)
    assert s.allow_nil?
    assert_schema_validate s, nil
    assert_equal(nil, s.sanitized_object)
    assert_schema_validate s, 42
    assert_not_nil(s.sanitized_object)
    assert_schema_invalidate(s, "wrong")
    assert_nil(s.sanitized_object)
  end

  def test_disallow_nil
    s = Respect::UTCTimeSchema.new
    assert !s.allow_nil?
    exception = assert_exception(Respect::ValidationError) { s.validate(nil) }
    assert_match /\bUTCTimeSchema\b/, exception.message
    assert_equal(nil, s.sanitized_object)
    assert_schema_validate s, 42
    assert_not_nil(s.sanitized_object)
    assert_schema_invalidate(s, "wrong")
    assert_nil(s.sanitized_object)
  end
end
