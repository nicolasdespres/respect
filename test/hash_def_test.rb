require "test_helper"

class HashDefTest < Test::Unit::TestCase

  def test_hash_schema_definition_accept_integer
    s = Respect::HashSchema.define do |s|
      s.integer "test", equal_to: 15
      s.extra do |s|
        s.integer "opt", equal_to: 43
      end
    end
    assert_schema_validate s, { "test" => "15", "opt" => "43" }
    assert_schema_validate s, { "test" => 15, "opt" => 43 }
  end

  def test_hash_schema_definition_accept_null
    s = Respect::HashSchema.define do |s|
      s.null "test"
      s.extra do |s|
        s.null "opt"
      end
    end
    assert_schema_validate s, { "test" => "null", "opt" => "null" }
    assert_schema_validate s, { "test" => nil, "opt" => nil }
  end

  def test_hash_schema_definition_accept_float
    s = Respect::HashSchema.define do |s|
      s.float "test", equal_to: 1.5
      s.extra do |s|
        s.float "opt", equal_to: 4.3
      end
    end
    assert_schema_validate s, { "test" => "1.5", "opt" => "4.3" }
    assert_schema_validate s, { "test" => 1.5, "opt" => 4.3 }
  end

  def test_hash_schema_definition_accept_boolean
    s = Respect::HashSchema.define do |s|
      s.boolean "test", equal_to: false
      s.extra do |s|
        s.boolean "opt", equal_to: false
      end
    end
    assert_schema_validate s, { "test" => "false", "opt" => "false" }
    assert_schema_validate s, { "test" => false, "opt" => false }
  end

  def test_hash_schema_definition_accept_array
    s = Respect::HashSchema.define do |s|
      s.array "test"
      s.extra do |s|
        s.array "opt"
      end
    end
    assert_schema_validate s, { "test" => [], "opt" => [] }
  end

  def test_cannot_overwrite_property
    assert_raise(Respect::InvalidSchemaError) do
      Respect::HashSchema.define do |s|
        s.integer "id", equal_to: 42
        s.integer "id", equal_to: 51
      end
    end
  end

  def test_extra_properties_overwrite_expected_ones
    assert_raise(Respect::InvalidSchemaError) do
      Respect::HashSchema.define(strict: true) do |s|
        s.integer "test", equal_to: 42
        s.extra do |s|
          s.integer "test", equal_to: 51
        end
      end
    end
  end

  def test_hash_scope_accept_options
    s = Respect::HashSchema.define do |s|
      s.hash "test", strict: true do |s|
        s.integer "test", equal_to: 42
      end
    end
    assert s["test"].options[:strict]
  end

  def test_factor_options_with_with_options
    s = Respect::HashSchema.define do |s|
      s.integer "test", equal_to: 42
      s.with_options required: false do |s|
        assert_nothing_raised("fake name proxy") do
          s.target
        end
        s.doc "doc opt1"
        s.integer "opt1", greater_than: 0
        s.doc "doc opt2"
        s.integer "opt2", less_than: 0
      end
    end
    assert_equal(42, s["test"].options[:equal_to])
    assert_equal(true, s["test"].options[:required])
    assert_equal(false, s["opt1"].options[:required])
    assert_equal(0, s["opt1"].options[:greater_than])
    assert_equal("doc opt1", s["opt1"].doc)
    assert_equal(false, s["opt2"].options[:required])
    assert_equal(0, s["opt2"].options[:less_than])
    assert_equal("doc opt2", s["opt2"].doc)
  end

  def test_key_assignment_with_string_value_create_string_schema_with_equal_to_validator
    h = Respect::HashSchema.define do |h|
      h["key"] = "value"
    end
    assert_equal Respect::StringSchema.new(equal_to: "value"), h["key"]
  end

  def test_assign_an_object_create_any_with_equal_to_validating_its_string_representation
    o = Object.new
    h = Respect::HashSchema.define do |h|
      h["any"] = o
    end
    s = Respect::AnySchema.new(equal_to: o.to_s)
    assert_equal s, h["any"]
  end
end
