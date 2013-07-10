require "test_helper"

class CompositeSchemaTest < Test::Unit::TestCase
  def test_failed_validation_reset_sanitized_object
    s = Respect::PointSchema.new
    assert_schema_validate(s, { x: 42.5, y: 51.3 })
    assert_equal(Point.new(42.5, 51.3), s.sanitized_object)
    assert_schema_invalidate(s, { x: 42.5 })
    assert_equal(nil, s.sanitized_object)
  end

  def test_allow_nil
    s = Respect::PointSchema.new(allow_nil: true)
    assert s.allow_nil?
    assert_schema_validate s, nil
    assert_equal(nil, s.sanitized_object)
    assert_schema_validate(s, { x: 42.5, y: 51.3 })
    assert_equal(Point.new(42.5, 51.3), s.sanitized_object)
  end

  def test_disallow_nil
    s = Respect::PointSchema.new
    assert !s.allow_nil?
    exception = assert_exception(Respect::ValidationError) { s.validate(nil) }
    assert_match /\bPointSchema\b/, exception.message
    assert_equal(nil, s.sanitized_object)
    assert_schema_validate(s, { x: 42.5, y: 51.3 })
    assert_equal(Point.new(42.5, 51.3), s.sanitized_object)
  end
end
