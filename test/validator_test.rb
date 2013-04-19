require "test_helper"

class ValidatorTest < Test::Unit::TestCase
  def test_constraint_name
    assert_equal "equal_to", Respect::EqualToValidator.constraint_name
  end
end
