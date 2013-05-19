require "test_helper"

class NumericSchemaTest < Test::Unit::TestCase
  def test_expected_value_are_not_converted
    s = Respect::NumericSchema.new(equal_to: "42.5")
    assert_raise(Respect::ValidationError) do
      s.validate(42.5)
    end
    s = Respect::NumericSchema.new(equal_to: "42")
    assert_raise(Respect::ValidationError) do
      s.validate(42)
    end
  end

  def test_malformed_string_value_raise_exception
    s = Respect::NumericSchema.new
    [
      "s42.5",
      "4s2.5",
      "42.5s",
      "4-2.5",
      "42.5-",
      "-+42.5",
      "+-42.5",
      "s42",
      "4s2",
      "42s",
      "4-2",
      "42-",
      "-+42",
      "+-42",
    ].each do |test_value|
      assert_schema_invalidate s, test_value, "#{test_value} is invalid"
    end
  end

  def test_string_value_get_converted
    [
      [ "-42.5",   -42.5 ],
      [ "+42.54",   42.54 ],
      [  "42.123",  42.123 ],
      [ "-42", -42 ],
      [ "+42",  42 ],
      [  "42",  42 ],
    ].each do |test_data|
      s = Respect::NumericSchema.new
      assert_equal test_data[1], s.validate_type(test_data[0])
      assert_nil s.sanitized_object
      s.validate(test_data[0])
      assert_equal test_data[1], s.sanitized_object
    end
  end

  def test_greater_than_constraint_works
    s = Respect::NumericSchema.new(greater_than: 0)
    assert s.validate(42.5)
    assert s.validate(42)
    [ 0, -42, 0.0, -42.5 ].each do |test_value|
      assert_raise(Respect::ValidationError) do
        s.validate(test_value)
      end
    end
  end

  def test_greater_than_or_equal_to_constraint_works
    s = Respect::NumericSchema.new(greater_than_or_equal_to: 0)
    assert s.validate(42.5)
    assert s.validate(0.0)
    assert s.validate(42)
    assert s.validate(0)
    [ -42, -42.5 ].each do |test_value|
      assert_raise(Respect::ValidationError) do
        s.validate(test_value)
      end
    end
  end

  def test_less_than_constraint_works
    s = Respect::NumericSchema.new(less_than: 0)
    assert s.validate(-1.5)
    assert s.validate(-1)
    [ 0.0, 1.5, 0, 1 ].each do |test_value|
      assert_raise(Respect::ValidationError) do
        s.validate(test_value)
      end
    end
  end

  def test_less_than_or_equal_to_constraint_works
    s = Respect::NumericSchema.new(less_than_or_equal_to: 0)
    assert s.validate(-1.5)
    assert s.validate(0.0)
    assert s.validate(-1)
    assert s.validate(0)
    [ 1.5, 1 ].each do |test_value|
      assert_raise(Respect::ValidationError) do
        s.validate(test_value)
      end
    end
  end

  def test_schema_definition_accept_numeric
    s = Respect::Schema.define do |s|
      s.numeric equal_to: 1.5
    end
    assert_schema_validate s, "1.5"
    assert_schema_validate s, 1.5

    s = Respect::Schema.define do |s|
      s.numeric equal_to: 1
    end
    assert_schema_validate s, "1"
    assert_schema_validate s, 1
  end

  def test_schema_definition_accept_numeric_with_no_option
    s = Respect::Schema.define do |s|
      s.numeric
    end
    assert_schema_validate s, 42
    assert_schema_validate s, 42.5
  end

  def test_hash_schema_definition_accept_numeric
    s = Respect::HashSchema.define do |s|
      s.numeric "test", equal_to: 1.5
      s.extra do |s|
        s.numeric "opt", equal_to: 4
      end
    end
    assert_schema_validate s, { "test" => "1.5", "opt" => "4" }
    assert_schema_validate s, { "test" => 1.5, "opt" => 4 }
  end

  def test_array_schema_definition_accept_numeric
    s = Respect::ArraySchema.define do |s|
      s.numeric equal_to: 1.5
    end
    assert_schema_validate s, ["1.5"]
    assert_schema_validate s, [1.5]

    s = Respect::ArraySchema.define do |s|
      s.numeric equal_to: 1
    end
    assert_schema_validate s, ["1"]
    assert_schema_validate s, [1]
  end

  def test_numeric_is_in_set
    s = Respect::NumericSchema.new(in: [42.5, 51.5, 42, 51])
    assert_schema_validate s, 42.5
    assert_schema_validate s, 51.5
    assert_schema_validate s, 42
    assert_schema_validate s, 51
    assert_schema_invalidate s, 1664.5
    assert_schema_invalidate s, 1664
  end

  def test_numeric_value_is_in_range
    s = Respect::NumericSchema.new(in: 1.5..4.5)
    assert_schema_invalidate s, 0.0
    assert_schema_invalidate s, 1.4
    assert_schema_validate s, 1.5
    assert_schema_validate s, 2.0
    assert_schema_validate s, 3.0
    assert_schema_validate s, 4.0
    assert_schema_validate s, 4.5
    assert_schema_invalidate s, 4.6
    assert_schema_invalidate s, 5.0

    s = Respect::NumericSchema.new(in: 1.5...4.5)
    assert_schema_invalidate s, 0.0
    assert_schema_invalidate s, 1.4
    assert_schema_validate s, 1.5
    assert_schema_validate s, 2.0
    assert_schema_validate s, 3.0
    assert_schema_validate s, 4.0
    assert_schema_invalidate s, 4.5
    assert_schema_invalidate s, 4.6
    assert_schema_invalidate s, 5.0

    s = Respect::NumericSchema.new(in: 1..4)
    assert_schema_invalidate s, 0
    assert_schema_validate s, 1
    assert_schema_validate s, 2
    assert_schema_validate s, 3
    assert_schema_validate s, 4
    assert_schema_invalidate s, 5

    s = Respect::NumericSchema.new(in: 1...4)
    assert_schema_invalidate s, 0
    assert_schema_validate s, 1
    assert_schema_validate s, 2
    assert_schema_validate s, 3
    assert_schema_invalidate s, 4
    assert_schema_invalidate s, 5
  end

  def test_numeric_accept_equal_to_constraint
    s = Respect::NumericSchema.new(equal_to: 41)
    assert_schema_validate s, 41
    assert_schema_validate s, 41.0
    assert_schema_validate s, "41"
    assert_schema_validate s, "41.0"
    assert_schema_invalidate s, 41.55
    assert_schema_invalidate s, 42
  end

  def test_divisible_by_and_multiple_of_option_works
    [ :divisible_by, :multiple_of ].each do |opt|
      # Works with integer
      s = Respect::NumericSchema.new(opt => 2)
      assert_schema_validate s, 4, "validate #{opt}"
      assert_schema_validate s, 2, "validate #{opt}"
      assert_schema_invalidate s, 1, "invalidate #{opt}"
      assert_schema_invalidate s, 3, "invalidate #{opt}"
      # Works with float
      s = Respect::NumericSchema.new(opt => 2.1)
      assert_schema_validate s, 4.2, "validate #{opt}"
      assert_schema_validate s, 2.1, "validate #{opt}"
      assert_schema_invalidate s, 1.4, "invalidate #{opt}"
      assert_schema_invalidate s, 3.4, "invalidate #{opt}"
    end
  end

  def test_divisible_by_option_mention_operands_in_error
    begin
      Respect::NumericSchema.new(divisible_by: 2).validate(3)
      assert false
    rescue Respect::ValidationError => e
      assert_match(/\b3\b/, e.message)
      assert_match(/\b2\b/, e.message)
      assert_match(/\bdivisible by\b/, e.message)
    end
  end

  def test_multiple_of_option_mention_operands_in_error
    begin
      Respect::NumericSchema.new(multiple_of: 2).validate(3)
      assert false
    rescue Respect::ValidationError => e
      assert_match(/\b3\b/, e.message)
      assert_match(/\b2\b/, e.message)
      assert_match(/\ba multiple of\b/, e.message)
    end
  end

  def test_failed_validation_reset_sanitized_object
    s = Respect::NumericSchema.new equal_to: 42
    assert_schema_validate(s, 42)
    assert_equal(42, s.sanitized_object)
    assert_schema_invalidate(s, "wrong")
    assert_equal(nil, s.sanitized_object)
  end

  def test_allow_nil
    s = Respect::NumericSchema.new(allow_nil: true)
    assert_schema_validate s, nil
    assert_equal(nil, s.sanitized_object)
    assert_schema_validate s, 42
    assert_equal(42, s.sanitized_object)
    assert_schema_validate s, "42"
    assert_equal(42, s.sanitized_object)
  end

  def test_disallow_nil
    s = Respect::NumericSchema.new
    assert !s.allow_nil?
    exception = assert_exception(Respect::ValidationError) { s.validate(nil) }
    assert_match exception.message, /\bNumericSchema\b/
    assert_equal(nil, s.sanitized_object)
    assert_schema_validate s, 42
    assert_equal(42, s.sanitized_object)
    assert_schema_validate s, "42"
    assert_equal(42, s.sanitized_object)
  end

  def test_allow_nil_with_constraint
    s = Respect::NumericSchema.new(allow_nil: true, equal_to: 42)
    assert_schema_validate s, nil
    assert_equal(nil, s.sanitized_object)
    assert_schema_validate s, 42
    assert_equal(42, s.sanitized_object)
    assert_schema_invalidate s, 51
    assert_equal(nil, s.sanitized_object)
    assert_schema_validate s, "42"
    assert_equal(42, s.sanitized_object)
  end

  def test_allow_nil_with_wrong_constraint_still_invalidate
    s = Respect::NumericSchema.new(allow_nil: true, equal_to: "42")
    assert_schema_invalidate s, "42"
  end
end
