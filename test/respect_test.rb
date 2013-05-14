require 'test_helper'

class RespectTest < Test::Unit::TestCase
  def test_schema_name_for
    [
      [ "foo", "Respect::FooSchema" ],
      [ "foo_bar", "Respect::FooBarSchema" ],
      [ "equal_to", "Respect::EqualToSchema", "regular" ],
      [ "a_b", "Respect::ABSchema", "two single letter menmonics" ],
      [ "a_b_", "Respect::ABSchema", "trailing underscore" ],
      [ "_a_b", "Respect::ABSchema", "leading underscore" ],
      [ "schema", "Respect::Schema", "special 'schema' case" ],
      [ :schema, "Respect::Schema", "special 'schema' case (symbol)" ],
      [ :string, "Respect::StringSchema", "string schema" ],
      [ :any, "Respect::AnySchema", "any schema" ],
      [ :circle, "Respect::CircleSchema", "user defined schema" ],
      [ :does_not_exist, "Respect::DoesNotExistSchema", "undefined schema" ],
      [ :request, "Respect::RequestSchema", "well named class but not a candidate" ],
    ].each do |data|
      assert_equal data[1], Respect.schema_name_for(data[0]), data[2]
    end
  end

  def test_schema_name_for_invalid_statement_names_raise_error
    assert_raises(ArgumentError) do
      Respect.schema_name_for("[]=")
    end
  end

  def test_schema_for
    {
      # root schema
      schema: nil,
      # internal schema definition
      string: Respect::StringSchema,
      integer: Respect::IntegerSchema,
      numeric: Respect::NumericSchema,
      float: Respect::FloatSchema,
      any: Respect::AnySchema,
      uri: Respect::URISchema,
      # user defined schema definition in support/respect
      circle: Respect::CircleSchema,
      point: Respect::PointSchema,
      rgba: Respect::RgbaSchema,
      # valid class but with no statement
      request: nil, # not a Schema sub-class
      composite: nil, # abstract
      undefined_schema: nil # undefined
    }.each do |statement, schema_class|
      klass = nil
      assert_nothing_raised("nothing raised for '#{statement}'") do
        klass = Respect.schema_for(statement)
      end
      assert_equal schema_class, klass, "correct class for '#{statement}'"
    end
  end

  def test_schema_defined_for
    assert_equal true,  Respect.schema_defined_for?("string")
    assert_equal false, Respect.schema_defined_for?("request"), "not a schema"
    assert_equal false, Respect.schema_defined_for?("composite"), "abstract"
    assert_equal false, Respect.schema_defined_for?("schema"), "root"
    assert_equal false, Respect.schema_defined_for?("undefined"), "undefined"
    assert_equal true, Respect.schema_defined_for?("hash"), "hash"
    assert_equal false, Respect.schema_defined_for?("object"), "object"
  end

  def test_validator_name_for
    [
      [ "equal_to", "Respect::EqualToValidator", "regular" ],
      [ "a_b", "Respect::ABValidator", "two single letter menmonics" ],
      [ "a_b_", "Respect::ABValidator", "trailing underscore" ],
      [ "_a_b", "Respect::ABValidator", "leading underscore" ],
    ].each do |data|
      assert_equal data[1], Respect.validator_name_for(data[0]), data[2]
    end
  end

  def test_validator_for
    {
      equal_to: Respect::EqualToValidator,
      format: Respect::FormatValidator,
      greater_than_or_equal_to: Respect::GreaterThanOrEqualToValidator,
      undefined_validator: nil # undefined
    }.each do |constraint, validator_class|
      klass = nil
      assert_nothing_raised("nothing raised for '#{constraint}'") do
        klass = Respect.validator_for(constraint)
      end
      assert_equal validator_class, klass, "correct class for '#{constraint}'"
    end
  end

  def test_validator_defined_for
    assert  Respect.validator_defined_for?(:equal_to)
    assert  Respect.validator_defined_for?(:format)
    assert  Respect.validator_defined_for?(:greater_than_or_equal_to)
    assert !Respect.validator_defined_for?(:undefined_validator)
  end

end
