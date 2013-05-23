require "test_helper"

class HashSchemaTest < Test::Unit::TestCase
  def test_validate_return_true_on_success
    s = Respect::HashSchema.define do |s|
      s.integer "id", equal_to: 42
    end
    assert s.validate({ "id" => 42 })

    s = Respect::HashSchema.new
    assert s.validate({})
  end

  def test_validate_raise_exception_on_error
    s = Respect::HashSchema.define do |s|
      s.integer "id", equal_to: 42
    end
    assert_raise(Respect::ValidationError) do
      s.validate({ "asdf" => 42 })
    end
  end

  def test_validate?
    s = Respect::HashSchema.define do |s|
      s.integer "id", equal_to: 42
    end
    assert_schema_invalidate s, { "asdf" => 42 }
  end

  def test_recursive_schema
    s = Respect::HashSchema.define do |s|
      s.hash "test" do |s|
        s.integer "test", equal_to: 42
      end
    end
    assert_schema_validate s, { "test" => { "test" => 42 } }
  end

  def test_hash_validate
    s = Respect::HashSchema.define do |s|
      s.integer "test", equal_to: 42
    end
    [
      [ {}, false, "empty hash" ],
      [ { "foo" => 42 }, false, "no expected property" ],
      [ { "test" => 42, "foo" => 60 }, true, "extra property" ],
    ].each do |data|
      assert_schema_validation_is data[1], s, data[0], data[2]
    end
  end

  def test_empty_hash_schema_validate_all_hash
    s = Respect::HashSchema.define do |s|
    end
    [
      [ {}, true, "empty hash" ],
      [ { "foo" => 42 }, true, "no expected property" ],
      [ { "test" => 42, "foo" => 60 }, true, "extra property" ],
    ].each do |data|
      assert_schema_validation_is data[1], s, data[0], data[2]
    end
  end

  def test_hash_schema_do_not_validate_other_type
    s = Respect::HashSchema.define do |s|
      s.integer "test", greater_than: 0
    end
    [
      [ { "test" => 1 } ],
      42,
      "test",
      nil,
    ].each do |doc|
      assert_raise(Respect::ValidationError) do
        s.validate(doc)
      end
    end
  end

  def test_hash_stricly_validate
    s = Respect::Schema.define do |s|
      s.hash strict: true do |s|
        s.integer "p1", equal_to: 3
        s.string "p2", equal_to: "val"
      end
    end
    [
      [ { "p1" => 3, "p2" => "val" }, true, "valid", ],
      [ { "p1" => 3 }, false, "not enough properties" ],
      [ { "p1" => 3, "p2" => "val", "additional" => "foo" }, false, "too many properties" ],
    ].each do |data|
      assert_schema_validation_is data[1], s, data[0], data[2]
    end
  end

  def test_optional_property
    s1 = Respect::HashSchema.define do |s|
      s.integer "test", equal_to: 42
      s.extra do |s|
        s.integer "opt", equal_to: 51
      end
    end
    s2 = Respect::HashSchema.define do |s|
      s.integer "test", equal_to: 42
      s.integer "opt", equal_to: 51, required: false
    end
    [
      [ {}, false, "empty hash", ],
      [ { "test" => 42 }, true, "only expected property", ],
      [ { "test" => 42, "opt" => 51 }, true, "expected and optional properties" ],
      [ { "test" => 42, "opt" => 64 }, false, "invalid optional property" ],
      [ { "test" => 54, "opt" => 51 }, false, "invalid expected property" ],
      [ { "opt" => 51 }, false, "only optional property" ],
      [ { "test" => 42, "extra" => 1, "opt" => 51 }, true, "extra and optional property" ],
      [ { "test" => 42, "extra" => 1 }, true, "extra property" ],
    ].each do |data|
      assert_schema_validation_is data[1], s1, data[0], data[2]
      assert_schema_validation_is data[1], s2, data[0], data[2]
    end
  end

  def test_optional_property_with_strict_validation
    s = Respect::HashSchema.define(strict: true) do |s|
      s.integer "test", equal_to: 42
      s.extra do |s|
        s.integer "opt", equal_to: 51
      end
    end
    [
      [ { "test" => 42, "extra" => 1, "opt" => 51 }, false, "extra and optional property" ],
      [ { "test" => 42, "extra" => 1 }, false, "extra property" ],
      [ { "test" => 42, "opt" => 51 }, true, "required and optional properties" ],
      [ { "test" => 42, }, true, "only required property" ],
    ].each do |data|
      assert_schema_validation_is data[1], s, data[0], data[2]
    end
  end

  def test_symbolized_property_name_are_kept_verbatim
    s = Respect::HashSchema.define do |s|
      s.integer :test, equal_to: 42
      s.extra do |s|
        s.integer :opt, equal_to: 51
      end
      s.string :foo, required: false
      s.hash :bar, default: { a: "b" }
      s.string "a_string"
      s.string /foo/
    end
    assert s.properties.has_key?(:test)
    assert s.properties.has_key?("a_string")
    assert s.properties.has_key?(/foo/)
    assert s.optional_properties.has_key?(:opt)
    assert s.optional_properties.has_key?(:foo)
    assert s.optional_properties.has_key?(:bar)
  end

  def test_symbol_key_are_stringified_at_validation
    s = Respect::HashSchema.define do |s|
      s.integer :test, equal_to: 42
    end
    assert_schema_validate s, { "test" => 42 }
    assert s.properties.has_key?(:test)
  end

  def test_can_define_empty_strict_hash_schema
    s = Respect::Schema.define do |s|
      s.hash strict: true
    end
    assert_equal true, s.options[:strict]
    assert_schema_validate s, {}
    assert_schema_invalidate s, { a: "b" }
  end

  def test_can_define_empty_hash_schema
    s = Respect::Schema.define do |s|
      s.hash
    end
    assert_equal false, s.options[:strict]
    assert_schema_validate s, {}
    assert_schema_validate s, { a: "b" }
  end

  def test_access_to_extra_properties
    s = Respect::HashSchema.define do |s|
      s.integer :test, equal_to: 42
      s.extra do |s|
        s.integer :opt, equal_to: 51
      end
      s.string :foo, required: false
      s.hash :bar, default: { a: "b" }
    end
    assert s.properties.has_key?(:test)
    assert s.properties.has_key?(:opt)
    assert s.properties.has_key?(:foo)
    assert s.properties.has_key?(:bar)
    assert !s.optional_properties.has_key?(:test)
    assert s.optional_properties.has_key?(:opt)
    assert s.optional_properties.has_key?(:foo)
    assert s.optional_properties.has_key?(:bar)
  end

  def test_default_value_used_when_property_unset
    s = Respect::HashSchema.define do |s|
      s.integer "test", default: 42
    end
    # Empty hash.
    s.validate({})
    assert_equal({ "test" => 42 }, s.sanitized_object)
    # Hash with extra property.
    s.validate({ "foo" => 51 })
    assert_equal({ "test" => 42 }, s.sanitized_object)
  end

  def test_default_value_do_not_override_defined_one
    s = Respect::HashSchema.define do |s|
      s.integer "test", default: 42
    end
    s.validate({ "test" => 54 })
    assert_equal({ "test" => 54 }, s.sanitized_object)
  end

  def test_validate_matched_properties
    s = Respect::HashSchema.define do |s|
      s.integer /test/, equal_to: 42
    end
    assert_schema_validate s, { "test" => 42, "_test_" => 42, "unmatch" => 51 }
    assert_schema_invalidate s, { "test" => 42, "_test_" => 51, "unmatch" => 51 }
  end

  def test_integer_invalid_property_name
    assert_raises(Respect::InvalidSchemaError) do
      Respect::HashSchema.define do |s|
        s.integer 42, equal_to: 42
      end
    end
  end

  def test_access_to_pattern_properties
    s = Respect::HashSchema.define do |s|
      s.integer "test", equal_to: 42
      s.string /foo/, equal_to: 51
    end
    assert s.properties.has_key?("test")
    assert s.properties.has_key?(/foo/)
    assert s.pattern_properties.has_key?(/foo/)
    assert !s.pattern_properties.has_key?("test")
  end

  def test_hash_schema_statement_expect_name_argument
    [
      :hash,
      :integer,
      :string,
      :array,
      :any,
      :boolean,
      :null,
      :float,
      :numeric,
    ].each do |meth_name|
      assert_raise(Respect::InvalidSchemaError) do
        Respect::HashSchema.define do |s|
          s.__send__(meth_name, {})
        end
      end
      assert_raise(Respect::InvalidSchemaError) do
        Respect::HashSchema.define do |s|
          s.extra do |s|
            s.__send__(meth_name, {})
          end
        end
      end
    end
  end

  def test_doc_updated_with_sanitized_value
    s = Respect::HashSchema.define do |s|
      s.integer "int", equal_to: 42
    end
    doc = { "int" => "42" }
    assert_not_nil s.validate!(doc)
    assert_equal 42, doc["int"]
  end

  def test_doc_updated_with_custom_type_sanitized_value
    s = Respect::HashSchema.define do |s|
      s.circle "circle"
    end
    doc = { "circle" => { "center" => { "x" => "1.0", "y" => "2.0" }, "radius" => "5.5" } }
    assert s.validate!(doc)
    assert_equal Circle.new(Point.new(1.0, 2.0), 5.0), doc["circle"]
  end

  def test_recursive_doc_updated_with_sanitized_value
    s = Respect::HashSchema.define do |s|
      s.integer "int", equal_to: 42
      s.hash "obj" do |s|
        s.integer "int", equal_to: 51
      end
    end
    doc = { "int" => "42", "obj" => { "int" => "51" } }
    assert_not_nil s.validate!(doc)
    assert_equal({ "int" => 42, "obj" => { "int" => 51 } }, doc)
  end

  def test_only_update_validated_properties
    s = Respect::HashSchema.define do |s|
      s.integer "int", equal_to: 42
    end
    doc = { "int" => "42", "not_validated" => "51" }
    assert_not_nil s.validate!(doc)
    assert_equal({ "int" => 42, "not_validated" => "51" }, doc)
  end

  def test_only_update_recursive_validated_properties
    s = Respect::HashSchema.define do |s|
      s.hash "obj" do |s|
        s.integer "int", equal_to: 42
      end
    end
    doc = { "obj" => { "int" => "42", "not_validated" => "51" } }
    assert_not_nil s.validate!(doc)
    assert_equal({ "obj" => { "int" => 42, "not_validated" => "51" } }, doc)
  end

  def test_sanitize_simple_document
    s = Respect::HashSchema.define do |s|
      s.integer "id", equal_to: 42
    end
    doc = { "id" => "42" }
    assert_nil s.sanitized_object
    s.validate(doc)
    assert_equal({ "id" => "42" }, doc)
    assert_equal({ "id" => 42 }, s.sanitized_object)
  end

  def test_sanitize_recursive_document
    s = Respect::HashSchema.define do |s|
      s.integer "id", equal_to: 42
      s.hash "obj" do |s|
        s.integer "id", equal_to: 51
      end
    end
    doc = { "id" => "42", "obj" => { "id" => "51" } }
    assert_nil s.sanitized_object
    s.validate(doc)
    assert_equal({ "id" => "42", "obj" => { "id" => "51" } }, doc)
    assert_equal({ "id" => 42, "obj" => { "id" => 51 } }, s.sanitized_object)
  end

  def test_do_not_sanitize_unvalidated_optional_property
    s = Respect::HashSchema.define do |s|
      s.integer "id1", equal_to: 42
      s.integer "id2", equal_to: 51, required: false
    end
    doc = { "id1" => "42" }
    assert_nil s.sanitized_object
    s.validate(doc)
    assert_equal({ "id1" => "42" }, doc)
    assert_equal({ "id1" => 42 }, s.sanitized_object)
  end

  def test_hash_schema_merge_default_options
    s = Respect::HashSchema.new
    assert_equal true, s.options[:required]
    assert_equal false, s.options[:strict]
  end

  def test_hash_schema_merge_options
    s = Respect::HashSchema.new(opt: 1, strict: true)
    assert_equal true, s.options[:required]
    assert_equal true, s.options[:strict]
    assert_equal 1, s.options[:opt]
  end

  def test_non_default_options
    s = Respect::HashSchema.new(opt: 1, strict: true)
    opts = s.non_default_options
    assert !opts.has_key?(:required)
    assert_equal true, opts[:strict]
    assert_equal 1, opts[:opt]
  end

  def test_has_property
    s1 = Respect::HashSchema.define do |s|
      s.integer "s11"
    end
    assert s1.has_property?("s11")
    assert !s1.has_property?("not a property")
  end

  def test_merge_hash_schema_in_place
    s1 = Respect::HashSchema.define opt0: false, opt1: false do |s|
      s.integer "s11"
      s.integer "s12"
    end
    s2 = Respect::HashSchema.define opt1: true, opt2: true do |s|
      s.integer "s21"
      s.integer "s22"
    end
    s1.merge!(s2)
    %w(s11 s12 s21 s22).each do |prop|
      assert s1.has_property?(prop), "has prop #{prop}"
    end
    assert_equal false, s1.options[:opt0]
    assert_equal true, s1.options[:opt1]
    assert_equal true, s1.options[:opt2]
  end

  def test_merge_hash_schema
    s1 = Respect::HashSchema.define do |s|
      s.integer "s11"
      s.integer "s12"
    end
    s2 = Respect::HashSchema.define do |s|
      s.integer "s21"
      s.integer "s22"
    end
    s3 = s1.merge(s2)
    assert(s3.object_id != s1.object_id)
    assert_equal 2, s1.properties.size
    assert_equal 2, s2.properties.size
    assert_equal 4, s3.properties.size
    %w(s11 s12 s21 s22).each do |prop|
      assert s3.has_property?(prop), "has prop #{prop}"
    end
  end

  def test_merge_uses_merge_shebang_on_duplicata
    s1 = Respect::HashSchema.new
    s2 = Respect::HashSchema.new
    result = Respect::HashSchema.new
    dup_s1 = Respect::HashSchema.new
    s1.stubs(:dup).returns(dup_s1).once
    dup_s1.stubs(:merge!).with(s2).returns(result).once
    assert_equal result, s1.merge(s2)
  end

  def test_dup_duplicate_properties_and_options
    s1 = Respect::HashSchema.define strict: true do |s|
      s.integer "s11"
    end
    s2 = s1.dup
    assert(s2.object_id != s1.object_id)
    assert(s1.properties.object_id != s2.properties.object_id)
    assert(s2.has_property?("s11"))
    assert_equal(true, s2.options[:strict])
    assert(s1["s11"].object_id == s2["s11"].object_id)
  end

  def test_eval_add_more_properties
    s1 = Respect::HashSchema.define do |s|
      s.integer "s11"
    end
    assert s1.has_property?("s11")
    assert !s1.has_property?("new_prop")
    s1.eval do |s|
      s.integer "new_prop"
    end
    assert s1.has_property?("s11")
    assert s1.has_property?("new_prop")
  end

  def test_documented_properties
    s = Respect::HashSchema.define do |s|
      s.integer "documented"
      s.integer "documented_with_text", doc: "a title"
      s.integer "nodoc", doc: false
    end
    e = %w(documented documented_with_text).sort
    assert_equal e, s.documented_properties.keys.sort
  end

  def test_duplicata_are_equal
    s1 = Respect::HashSchema.define do |s|
      s.integer "i"
    end
    assert_equal s1, s1.dup
  end

  def test_schema_differs_from_options
    s1 = Respect::HashSchema.new(required: true)
    s2 = Respect::HashSchema.new(required: false)
    assert(s1 != s2)
  end

  def test_schema_differs_from_doc
    s1 = Respect::Schema.define do |s|
      s.doc "hey"
      s.hash
    end
    s2 = Respect::Schema.define do |s|
      s.doc "ho"
      s.hash
    end
    assert(s1 != s2)
  end

  def test_schema_differs_from_properties
    s1 = Respect::HashSchema.new
    s1["i1"] = Respect::IntegerSchema.new
    s2 = Respect::HashSchema.new
    s2["i2"] = Respect::IntegerSchema.new
    assert(s1 != s2)
  end

  def test_indifferent_access_to_doc_key
    s = Respect::HashSchema.define do |s|
      s.integer "i", equal_to: 42
    end
    assert_schema_validate(s, { i: "42" })
    assert_schema_validate(s, { "i" => "42" })
    assert_schema_invalidate(s, { })
  end

  def test_doc_sanitized_in_place_keep_original_access
    s = Respect::HashSchema.define do |s|
      s.integer "i_string", equal_to: 42
      s.integer :i_symbol, equal_to: 51
    end

    doc = { i_string: "42", "i_symbol" => "51" }
    assert_schema_validate(s, doc)
    assert !doc.is_a?(HashWithIndifferentAccess)
    assert_equal(42, s.sanitized_object[:i_string])
    assert_equal(42, s.sanitized_object["i_string"])
    assert_equal(51, s.sanitized_object[:i_symbol])
    assert_equal(51, s.sanitized_object["i_symbol"])

    assert s.sanitized_object.is_a?(HashWithIndifferentAccess)
    assert_equal({ "i_string" => 42, "i_symbol" => 51 }, s.sanitized_object)

    s.sanitize_object!(doc)
    assert_equal({ i_string: 42, "i_symbol" => 51 }, doc)
  end

  def test_indifferent_access_to_doc_nil_values
    s = Respect::HashSchema.define do |s|
      s.null "n"
    end
    assert_schema_validate(s, { n: nil })
    assert_schema_validate(s, { "n" => nil })
    assert_schema_invalidate(s, { })
  end

  def test_indifferent_access_to_doc_false_values
    s = Respect::HashSchema.define do |s|
      s.boolean "b", equal_to: false
    end
    assert_schema_validate(s, { b: false })
    assert_schema_validate(s, { "b" => false })
    assert_schema_invalidate(s, { })
  end

  def test_sanitized_object_only_include_validated_keys
    s = Respect::HashSchema.define do |s|
      s.integer "i"
    end
    assert_schema_validate(s, { i: "42", foo: "bar" })
    assert_equal({ "i" => 42 }, s.sanitized_object)
  end

  def test_sanitized_object_include_optional_keys_when_present
    s = Respect::HashSchema.define do |s|
      s.integer "i", required: false
    end
    assert_schema_validate(s, { i: "42", foo: "bar" })
    assert_equal({ "i" => 42 }, s.sanitized_object)
    assert_schema_validate(s, { foo: "bar" })
    assert_equal({ }, s.sanitized_object)
  end

  def test_failed_validation_reset_sanitized_object
    s = Respect::HashSchema.define do |s|
      s.integer "i", equal_to: 42
    end
    assert_schema_validate(s, {i: 42})
    assert_equal({"i" => 42}, s.sanitized_object)
    assert_schema_invalidate(s, {i: 51})
    assert_equal(nil, s.sanitized_object)
  end

  def test_integer_property_accept_nil
    s = Respect::HashSchema.define do |s|
      s.integer "i", allow_nil: true
    end
    assert_schema_validate(s, { i: nil })
    assert_equal({ "i" => nil }, s.sanitized_object)
    assert_schema_validate(s, { i: 42 })
    assert_equal({ "i" => 42 }, s.sanitized_object)
    assert_schema_invalidate(s, { i: "wrong" })
    assert_equal(nil, s.sanitized_object)
  end

  def test_allow_nil
    s = Respect::HashSchema.new(allow_nil: true)
    assert_schema_validate s, nil
    assert_equal(nil, s.sanitized_object)
    assert_schema_validate s, {}
    assert_equal({}, s.sanitized_object)
  end

  def test_disallow_nil
    s = Respect::HashSchema.new
    assert !s.allow_nil?
    exception = assert_exception(Respect::ValidationError) { s.validate(nil) }
    assert_match exception.message, /\bHashSchema\b/
    assert_equal(nil, s.sanitized_object)
    assert_schema_validate s, {}
    assert_equal({}, s.sanitized_object)
  end
end
