require "test_helper"

class AnySchemaTest < Test::Unit::TestCase
  def test_any_schema_validate_any_value
    s1 = Respect::AnySchema.new
    s2 = Respect::Schema.define do |s|
      s.any
    end
    s3 = Respect::HashSchema.define do |s|
      s.any "test"
      s.extra do |s|
        s.any "opt"
      end
    end
    [
      [ { "test" => 42 }, true, "hash" ],
      [ [ 42 ], true, "array" ],
      [ 42, true, "integer" ],
      [ 42.5, true, "float" ],
      [ "test", true, "string" ],
      [ false, true, "false boolean" ],
      [ true, true, "true boolean" ],
      [ nil, true, "null" ],
      [ Object.new, false, "unknown type" ],
    ].each do |data|
      assert_schema_validation_is data[1], s1, data[0], data[2]
      assert_schema_validation_is data[1], s2, data[0], data[2]
      assert_schema_validation_is data[1], s3["test"], data[0], data[2]
      assert_schema_validation_is data[1], s3.optional_properties["opt"], data[0], data[2]
    end
  end

  def test_any_schema_do_not_convert_anything
    [
      [ { "test" => 42 }, "hash" ],
      [ [ 42 ], "array" ],
      [ 42, "integer" ],
      [ 42.5, "float" ],
      [ "test", "string" ],
      [ false, "false boolean" ],
      [ true, "true boolean" ],
      [ nil, "null" ],
      [ Object.new, "unknown type" ],
    ].each do |data|
      s = Respect::AnySchema.new
      assert_nil s.sanitized_object
      if s.validate?(data[0])
        assert_equal data[0], s.sanitized_object, data[1]
      else
        assert_nil s.sanitized_object, data[1]
      end
    end
  end

  def test_failed_validation_reset_sanitized_object
    s = Respect::AnySchema.define equal_to: 42
    assert_schema_validate(s, 42)
    assert_equal(42, s.sanitized_object)
    assert_schema_invalidate(s, Object.new)
    assert_equal(nil, s.sanitized_object)
  end
end
