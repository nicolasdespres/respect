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

end
