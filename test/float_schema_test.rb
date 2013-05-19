require "test_helper"

class FloatSchemaTest < Test::Unit::TestCase
  def test_expected_value_are_not_converted
    s = Respect::FloatSchema.new(equal_to: "42.5")
    assert_raise(Respect::ValidationError) do
      s.validate(42.5)
    end
  end

  def test_malformed_string_value_raise_exception
    s = Respect::FloatSchema.new
    [
      "s42.5",
      "4s2.5",
      "42.5s",
      "4-2.5",
      "42.5-",
      "-+42.5",
      "+-42.5",
    ].each do |test_value|
      assert_raise(Respect::ValidationError) do
        s.validate_type(test_value)
      end
    end
  end

  def test_string_value_get_converted
    [
      [ "-42.5",   -42.5 ],
      [ "+42.54",   42.54 ],
      [  "42.123",  42.123 ],
    ].each do |test_data|
      s = Respect::FloatSchema.new
      assert_equal test_data[1], s.validate_type(test_data[0])
      assert_nil s.sanitized_object
      s.validate(test_data[0])
      assert_equal test_data[1], s.sanitized_object
    end
  end

  def test_greater_than_constraint_works
    s = Respect::FloatSchema.new(greater_than: 0)
    assert s.validate(42.5)
    [ 0.0, -42.5 ].each do |test_value|
      assert_raise(Respect::ValidationError) do
        s.validate(test_value)
      end
    end
  end

  def test_greater_than_or_equal_to_constraint_works
    s = Respect::FloatSchema.new(greater_than_or_equal_to: 0)
    assert s.validate(42.5)
    assert s.validate(0.0)
    assert_raise(Respect::ValidationError) do
      s.validate(-42.5)
    end
  end

  def test_less_than_constraint_works
    s = Respect::FloatSchema.new(less_than: 0)
    assert s.validate(-1.5)
    [ 0.0, 1.5 ].each do |test_value|
      assert_raise(Respect::ValidationError) do
        s.validate(test_value)
      end
    end
  end

  def test_less_than_or_equal_to_constraint_works
    s = Respect::FloatSchema.new(less_than_or_equal_to: 0)
    assert s.validate(-1.5)
    assert s.validate(0.0)
    assert_raise(Respect::ValidationError) do
      s.validate(1.5)
    end
  end

  def test_float_value_is_in_set
    s = Respect::FloatSchema.new(in: [42.5, 51.5])
    assert_schema_validate s, 42.5
    assert_schema_validate s, 51.5
    assert_schema_invalidate s, 1664.5
  end

  def test_float_value_is_in_range
    s = Respect::FloatSchema.new(in: 1.5..4.5)
    assert_schema_invalidate s, 0.0
    assert_schema_invalidate s, 1.4
    assert_schema_validate s, 1.5
    assert_schema_validate s, 2.0
    assert_schema_validate s, 3.0
    assert_schema_validate s, 4.0
    assert_schema_validate s, 4.5
    assert_schema_invalidate s, 4.6
    assert_schema_invalidate s, 5.0

    s = Respect::FloatSchema.new(in: 1.5...4.5)
    assert_schema_invalidate s, 0.0
    assert_schema_invalidate s, 1.4
    assert_schema_validate s, 1.5
    assert_schema_validate s, 2.0
    assert_schema_validate s, 3.0
    assert_schema_validate s, 4.0
    assert_schema_invalidate s, 4.5
    assert_schema_invalidate s, 4.6
    assert_schema_invalidate s, 5.0
  end

  def test_float_accept_equal_to_constraint
    s = Respect::FloatSchema.new(equal_to: 41.5)
    assert_schema_validate s, 41.5
    assert_schema_invalidate s, 41.55
  end

  def test_failed_validation_reset_sanitized_object
    s = Respect::FloatSchema.new equal_to: 42.5
    assert_schema_validate(s, 42.5)
    assert_equal(42.5, s.sanitized_object)
    assert_schema_invalidate(s, "wrong")
    assert_equal(nil, s.sanitized_object)
  end
end
