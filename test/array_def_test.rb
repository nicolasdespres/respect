require "test_helper"

class ArrayDefTest < Test::Unit::TestCase

  def test_array_schema_definition_accept_integer
    s = Respect::ArraySchema.define do |s|
      s.integer equal_to: 15
    end
    assert s.validate?(["15"])
    assert s.validate?([15])
  end

  def test_array_schema_definition_accept_null
    s = Respect::ArraySchema.define do |s|
      s.null
    end
    assert s.validate?(["null"])
    assert s.validate?([nil])
  end

  def test_array_schema_definition_accept_float
    s = Respect::ArraySchema.define do |s|
      s.float equal_to: 1.5
    end
    assert s.validate?(["1.5"])
    assert s.validate?([1.5])
  end

  def test_array_schema_definition_accept_boolean
    s = Respect::ArraySchema.define do |s|
      s.boolean equal_to: true
    end
    assert s.validate?(["true"])
    assert s.validate?([true])
  end

  def test_array_schema_definition_accept_array
    s = Respect::ArraySchema.define do |s|
      s.items do |s|
        s.array
      end
    end
    assert s.validate?([[]])
    assert s.validate?([[]])
  end

  def test_array_schema_statement_cannot_accept_name_argument
    [
      :object,
      :integer,
      :string,
      :array,
      :any,
      :boolean,
      :null,
      :float,
      :numeric,
    ].each do |meth_name|
      assert_raise(ArgumentError) do
        Respect::ArraySchema.define do |s|
          s.__send__(meth_name, "prop", {})
        end
      end
      assert_raise(ArgumentError) do
        Respect::ArraySchema.define do |s|
          s.items do |s|
            s.__send__(meth_name, "prop", {})
          end
        end
      end
      assert_raise(ArgumentError) do
        Respect::ArraySchema.define do |s|
          s.extra_items do |s|
            s.__send__(meth_name, "prop", {})
          end
        end
      end
    end
  end

  def test_factor_options_with_with_options
    s = Respect::ArraySchema.define do |s|
      s.items do |s|
        s.doc "integer doc"
        s.integer equal_to: 42
        s.with_options required: false do |s|
          assert_nothing_raised("fake name proxy") do
            s.target
          end
          s.doc "float doc"
          s.float greater_than: 0
          s.doc "numeric doc"
          s.numeric less_than: 0
        end
      end
    end

    assert_equal(Respect::IntegerSchema, s.items[0].class)
    assert_equal(42, s.items[0].options[:equal_to])
    assert_equal(true, s.items[0].options[:required])
    assert_equal("integer doc", s.items[0].doc)

    assert_equal(Respect::FloatSchema, s.items[1].class)
    assert_equal(false, s.items[1].options[:required])
    assert_equal(0, s.items[1].options[:greater_than])
    assert_equal("float doc", s.items[1].doc)

    assert_equal(Respect::NumericSchema, s.items[2].class)
    assert_equal(false, s.items[2].options[:required])
    assert_equal(0, s.items[2].options[:less_than])
    assert_equal("numeric doc", s.items[2].doc)
  end
end
