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

  def test_array_schema_command_cannot_accept_name_argument
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

end
