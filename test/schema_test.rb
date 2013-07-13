require "test_helper"

class SchemaTest < Test::Unit::TestCase
  def test_validate_value_return_true_on_success
    s = Respect::HashSchema.define do |s|
      s.string "test", equal_to: "value"
    end
    assert s.validate({ "test" => "value" })
  end

  def test_no_exception_raised_for_invalid_constraint
    s = Respect::HashSchema.define do |s|
      s.string "test", invalid_constraint: "value"
    end
    assert_nothing_raised do
      assert s.validate({ "test" => "value" })
    end
  end

  def test_access_to_sanitized_value
    s = Respect::IntegerSchema.new(equal_to: 42)
    doc = "42"
    assert s.validate(doc)
    assert_equal 42, s.sanitized_object
  end

  def test_validate_query_does_not_raise_exception_when_invalid
    s = Respect::HashSchema.define do |s|
      s.string "test", equal_to: "value"
    end
    assert_schema_validate s, { "test" => "value" }
    assert_schema_invalidate s, { "test" => "invalid" }
  end

  def test_non_collection_schema_validation_error_have_context
    s = Respect::Schema.define do |s|
      s.string equal_to: "value"
    end
    assert_schema_invalidate s, "invalid"
    assert_equal 1, s.last_error.context.size
    assert (s.last_error.message == s.last_error.context.first)
  end

  def test_hash_schema_validation_error_have_context
    s = Respect::HashSchema.define do |s|
      s.string "test", equal_to: "value"
    end
    assert_schema_invalidate s, { "test" => "invalid" }
    assert_equal 2, s.last_error.context.size
    assert_hash_context_error_message("test", s.last_error.context.last)
  end

  def test_array_schema_validation_error_have_context
    s = Respect::ArraySchema.define do |s|
      s.numeric
    end
    assert_schema_invalidate s, [1, "invalid", 3]
    assert_equal 2, s.last_error.context.size
    assert_array_context_error_message(1, s.last_error.context.last)
  end

  def test_error_context_can_be_nested
    s = Respect::HashSchema.define do |s|
      s.hash "level_1" do |s|
        s.array "level_2" do |s|
          s.hash do |s|
            s.numeric "level_4", equal_to: 51
          end
        end
      end
    end
    doc = {
      "level_1" => {
        "level_2" => [
          { "level_4" => 42 }
        ]
      }
    }
    assert_schema_invalidate s, doc
    assert_equal 5, s.last_error.context.size
    assert_hash_context_error_message("level_4", s.last_error.context[1])
    assert_array_context_error_message("0", s.last_error.context[2])
    assert_hash_context_error_message("level_2", s.last_error.context[3])
    assert_hash_context_error_message("level_1", s.last_error.context[4])
  end

  def test_schema_to_s_as_dsl
    s = Respect::HashSchema.new
    d = Respect::DslDumper.new(s)
    Respect::DslDumper.expects(:new).with(s).returns(d)
    d.stubs(:dump).at_least_once
    s.to_s
  end

  def test_schema_to_json_org3
    h = {}
    h.stubs(:to_json).returns('json string').at_least_once

    s = Respect::HashSchema.new
    s.stubs(:to_h).with(:org3).returns(h).at_least_once

    assert_equal("json string", s.to_json(:org3))
  end

  def test_schema_to_h_as_org3
    s = Respect::HashSchema.new
    d = Respect::Org3Dumper.new(s)
    Respect::Org3Dumper.expects(:new).with(s).returns(d)
    d.stubs(:dump).returns("json hash").at_least_once
    assert_equal("json hash",  s.to_h(:org3))
  end

  def test_def_class_name
    assert_equal "Respect::SchemaDef", Respect::Schema.def_class_name
    assert_equal "Respect::ArrayDef", Respect::ArraySchema.def_class_name
    assert_equal "Respect::HashDef", Respect::HashSchema.def_class_name
    assert_equal "Respect::StringDef", Respect::StringSchema.def_class_name
  end

  def test_def_class
    assert_equal Respect::SchemaDef, Respect::Schema.def_class
    assert_equal Respect::ArrayDef, Respect::ArraySchema.def_class
    assert_equal Respect::HashDef, Respect::HashSchema.def_class
    assert_equal nil, Respect::StringSchema.def_class
  end

  def test_statement_name
    assert_equal "string", Respect::StringSchema.statement_name
    assert_equal "integer", Respect::IntegerSchema.statement_name
    assert_equal "schema", Respect::Schema.statement_name
    assert_equal "circle", Respect::CircleSchema.statement_name
    assert_equal "point", Respect::PointSchema.statement_name
  end

  def test_in_place_validation_always_return_boolean
    s = Respect::Schema.define do |s|
      s.boolean
    end
    assert_equal true, s.validate!(false)
    assert_equal true, s.validate!(true)
    assert_equal false, s.validate!(nil)
  end

  def test_sanitize_always_return_new_object
    s = Respect::Schema.define do |s|
      s.boolean
    end
    assert_equal false, s.sanitize!(false)
    assert_equal true, s.sanitize!(true)
    assert_raise(Respect::ValidationError) do
      s.sanitize!(nil)
    end
  end

  def test_schema_accept_doc_option
    s = Respect::IntegerSchema.new(doc: "Hey!")
    assert_equal "Hey!", s.doc
    assert_equal "Hey!", s.options[:doc]
  end

  def test_duplicata_are_equal
    s1 = Respect::IntegerSchema.new
    assert_equal s1, s1.dup
  end

  def test_schema_differs_from_options
    s1 = Respect::IntegerSchema.new(required: true)
    s2 = Respect::IntegerSchema.new(required: false)
    assert(s1 != s2)
  end

  def test_schema_differs_from_doc
    s1 = Respect::Schema.define do |s|
      s.doc "hey"
      s.integer
    end
    s2 = Respect::Schema.define do |s|
      s.doc "ho"
      s.integer
    end
    assert(s1 != s2)
  end

  def test_schema_differs_from_type
    s1 = Respect::IntegerSchema.new
    s2 = Respect::StringSchema.new
    assert(s1 != s2)
  end

  def test_schema_differs_from_validator
    s1 = Respect::IntegerSchema.new(equal_to: 42)
    s2 = Respect::IntegerSchema.new(equal_to: 51)
    assert(s1 != s2)
  end

  def test_schema_dont_differs_from_sanitized_object
    s1 = Respect::IntegerSchema.new
    s1.send(:sanitized_object=, 42)
    s2 = Respect::IntegerSchema.new
    s2.send(:sanitized_object=, 51)
    assert(s1 == s2)
  end

  def test_dup_duplicate_options
    s1 = Respect::IntegerSchema.define equal_to: 42
    s2 = s1.dup
    assert(s2.object_id != s1.object_id)
    assert_equal(42, s2.options[:equal_to])
  end

  def test_validate_query_returns_true_when_no_error
    s = Respect::Schema.send(:new)
    doc = {}
    s.stubs(:validate).with(doc).returns(nil).once
    assert_equal true, s.validate?(doc)
  end

  def test_validate_query_returns_false_on_error_and_store_last_error
    s = Respect::Schema.send(:new)
    doc = {}
    error = Respect::ValidationError.new("message")
    s.stubs(:validate).with(doc).raises(error).once
    assert_equal false, s.validate?(doc)
    assert_equal error, s.last_error
  end

  def test_validate_shebang_returns_true_on_success_and_sanitize
    s = Respect::Schema.send(:new)
    doc = {}
    s.stubs(:validate?).with(doc).returns(true).once
    s.stubs(:sanitize_object!).with(doc).once
    assert_equal true, s.validate!(doc)
  end

  def test_validate_shebang_returns_false_on_failure
    s = Respect::Schema.send(:new)
    doc = {}
    s.stubs(:validate?).with(doc).returns(false).once
    assert_equal false, s.validate!(doc)
  end

  def test_sanitize_shebang_raises_exception_on_error
    s = Respect::Schema.send(:new)
    doc = {}
    error = Respect::ValidationError.new("message")
    s.stubs(:validate).with(doc).raises(error).once
    begin
      s.sanitize!(doc)
      assert false, "nothing raised"
    rescue Respect::ValidationError => e
      assert_equal error, e
    end
  end

  def test_sanitize_shebang_sanitize_on_success
    s = Respect::Schema.send(:new)
    doc = {}
    s.stubs(:validate).with(doc).once
    result = Object.new
    s.stubs(:sanitize_object!).with(doc).returns(result).once
    assert_equal result.object_id, s.sanitize!(doc).object_id
  end

  def test_sanitize_doc_shebang
    s = Respect::Schema.send(:new)
    doc = {}
    sanitized_object = {}
    s.stubs(:sanitized_object).with().returns(sanitized_object).once
    result = Object.new
    Respect.stubs(:sanitize_object!).with(doc, sanitized_object).returns(result).once
    assert_equal result.object_id, s.sanitize_object!(doc).object_id
  end

  def test_explain_validator_option
    s = Respect::IntegerSchema.new(equal_to: 42)
    v = Respect::EqualToValidator.new(42)
    Respect::EqualToValidator.expects(:new).with(42).returns(v).once
    result = "a string"
    v.stubs(:explain).returns(result).once
    assert_equal result.object_id, s.explain_option(:equal_to).object_id
  end

  def test_explain_unknown_option
    s = Respect::IntegerSchema.new(unknown: 42)
    assert_kind_of String, s.explain_option(:unknown)
  end

  def test_explain_required_with_no_default_value
    s = Respect::IntegerSchema.new(required: true)
    explanation = s.explain_option(:required)



  end

  private

  def assert_hash_context_error_message(prop_name, message)
    [ /\bin\b/, /\bhash\b/, /\bproperty\b/, /\b#{prop_name}\b/ ].each do |rx|
      assert(rx =~ message,
        "error message '#{message}' does not match #{rx}")
    end
  end

  def assert_array_context_error_message(index, message)
    [ /\bin\b/, /\barray\b/, /\bitem\b/, /\b#{index}/ ].each do |rx|
      assert(rx =~ message,
        "error message '#{message}' does not match #{rx}")
    end
  end

end
