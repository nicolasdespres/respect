require "test_helper"

class ValidatorTest < Test::Unit::TestCase
  def test_constraint_name
    assert_equal "equal_to", Respect::EqualToValidator.constraint_name
  end

  def test_end_user_validator
    s = Respect::IntegerSchema.new(universal: true)
    assert_schema_invalidate s, 52
    assert_schema_validate s, 42
  end

  def test_end_user_validate_get_called
    value = 1664
    v = Respect::UniversalValidator.new(true)
    Respect::UniversalValidator.expects(:new).with(true).returns(v)
    v.stubs(:validate).with(value).at_least_once
    Respect::IntegerSchema.new(universal: true).validate(value)
  end

end
