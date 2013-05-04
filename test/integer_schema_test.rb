require "test_helper"

class IntegerSchemaTest < Test::Unit::TestCase
  def test_expected_value_are_not_converted
    s = Respect::IntegerSchema.new(equal_to: "42")
    assert_raise(Respect::ValidationError) do
      s.validate(42)
    end
  end

  def test_malformed_string_value_raise_exception
    s = Respect::IntegerSchema.new
    [
      "s42",
      "4s2",
      "42s",
      "4-2",
      "42-",
      "-+42",
      "+-42",
      "42.5",
      "0.5",
    ].each do |test_value|
      assert_raise(Respect::ValidationError) do
        s.validate_format(test_value)
      end
    end
  end

  def test_string_value_get_converted
    [
      [ "-42", -42 ],
      [ "+42",  42 ],
      [  "42",  42 ],
    ].each do |test_data|
      s = Respect::IntegerSchema.new
      assert_equal test_data[1], s.validate_format(test_data[0])
      assert_nil s.sanitized_doc
      s.validate(test_data[0])
      assert_equal test_data[1], s.sanitized_doc
    end
  end

  def test_integer_accept_equal_to_constraint
    s = Respect::IntegerSchema.new(equal_to: 41)
    assert_schema_validate s, 41
    assert_schema_invalidate s, 52
  end

  def test_greater_than_constraint_works
    s = Respect::IntegerSchema.new(greater_than: 0)
    assert s.validate(42)
    [ 0, -42 ].each do |test_value|
      assert_raise(Respect::ValidationError) do
        s.validate(test_value)
      end
    end
  end

  def test_greater_than_or_equal_to_constraint_works
    s = Respect::IntegerSchema.new(greater_than_or_equal_to: 0)
    assert s.validate(42)
    assert s.validate(0)
    assert_raise(Respect::ValidationError) do
      s.validate(-42)
    end
  end

  def test_less_than_constraint_works
    s = Respect::IntegerSchema.new(less_than: 0)
    assert s.validate(-1)
    [ 0, 1 ].each do |test_value|
      assert_raise(Respect::ValidationError) do
        s.validate(test_value)
      end
    end
  end

  def test_less_than_or_equal_to_constraint_works
    s = Respect::IntegerSchema.new(less_than_or_equal_to: 0)
    assert s.validate(-1)
    assert s.validate(0)
    assert_raise(Respect::ValidationError) do
      s.validate(1)
    end
  end

  def test_integer_value_is_in_set
    s = Respect::IntegerSchema.new(in: [42, 51])
    assert_schema_validate s, 42
    assert_schema_validate s, 51
    assert_schema_invalidate s, 1664
  end

  def test_integer_value_is_in_range
    s = Respect::IntegerSchema.new(in: 1..4)
    assert_schema_invalidate s, 0
    assert_schema_validate s, 1
    assert_schema_validate s, 2
    assert_schema_validate s, 3
    assert_schema_validate s, 4
    assert_schema_invalidate s, 5

    s = Respect::IntegerSchema.new(in: 1...4)
    assert_schema_invalidate s, 0
    assert_schema_validate s, 1
    assert_schema_validate s, 2
    assert_schema_validate s, 3
    assert_schema_invalidate s, 4
    assert_schema_invalidate s, 5
  end

end
