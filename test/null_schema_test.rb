require "test_helper"

class NullSchemaTest < Test::Unit::TestCase
  def test_null_schema_validate_format
    # Malformed document.
    [
      [ "42", false, "integer in string" ],
      [ { "test" => 42 }, false, "hash" ],
      [ "true", false, "true in string" ],
      [ "false", false, "false in string" ],
      [ "string", false, "string" ],
      [ "nil", false, "nil in string" ],
      [ nil, true, "nil" ],
      [ "null", true, "null in string" ],
    ].each do |data|
      s = Respect::NullSchema.new
      assert_nil s.sanitized_object
      validated = s.validate?(data[0])
      assert_equal data[1], validated, data[2]
      if validated
        assert_nil s.sanitized_object, data[2]
      end
    end
  end

  def test_failed_validation_reset_sanitized_object
    s = Respect::NullSchema.new
    assert_schema_validate(s, nil)
    assert_equal(nil, s.sanitized_object)
    assert_schema_invalidate(s, 42)
    assert_equal(nil, s.sanitized_object)
  end
end
