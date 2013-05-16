require "test_helper"

class BooleanSchemaTest < Test::Unit::TestCase
  def test_boolean_schema_validate_type
    [
      [ "42", nil, "integer in string" ],
      [ { "test" => 42 }, nil, "hash" ],
      [ "true", true, "valid true value" ],
      [ "false", false, "valid false value" ],
      [ true, true, "true" ],
      [ false, false, "false" ],
      [ "nil", nil, "nil in string" ],
    ].each do |data|
      s = Respect::BooleanSchema.new
      # Check validate_type
      if data[1].nil?
        assert_raise(Respect::ValidationError) do
          s.validate_type(data[0])
        end
      else
        assert_equal data[1], s.validate_type(data[0]), data[2]
      end
      # Check sanitized_object
      assert_nil s.sanitized_object
      assert_schema_validation_is (data[1].nil? ? false : true), s, data[0], data[2]
      unless data[1].nil?
        assert_equal data[1], s.sanitized_object, data[2]
      end
    end
  end

  def test_boolean_schema_accept_constraint_equal_to
    s_true = Respect::BooleanSchema.new equal_to: true
    assert_schema_validation_is true, s_true, "true"
    assert_schema_validation_is false, s_true, "false"

    s_false = Respect::BooleanSchema.new equal_to: false
    assert_schema_validation_is false, s_false, "true"
    assert_schema_validation_is true, s_false, "false"
  end

end
