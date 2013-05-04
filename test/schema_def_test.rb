require "test_helper"

class SchemaDefTest < Test::Unit::TestCase

  def setup
    @title = "This is a title."
    @description = <<-EOS.strip_heredoc
      This a long description...

      ...with blank line.
      EOS
    @doc = "#@title\n\n#@description"
  end

  def test_schema_definition_accept_string_with_no_option
    s = Respect::Schema.define do |s|
      s.string
    end
    assert_schema_validate s, "foo"
  end

  def test_schema_definition_accept_integer
    s = Respect::Schema.define do |s|
      s.integer equal_to: 15
    end
    assert_schema_validate s, "15"
    assert_schema_validate s, 15
  end

  def test_schema_definition_accept_integer_with_no_option
    s = Respect::Schema.define do |s|
      s.integer
    end
    assert_schema_validate s, 42
  end

  def test_schema_definition_accept_null
    s = Respect::Schema.define do |s|
      s.null
    end
    assert_schema_validate s, "null"
  end

  def test_schema_definition_accept_float
    s = Respect::Schema.define do |s|
      s.float equal_to: 1.5
    end
    assert_schema_validate s, "1.5"
    assert_schema_validate s, 1.5
  end

  def test_schema_definition_accept_float_with_no_option
    s = Respect::Schema.define do |s|
      s.float
    end
    assert_schema_validate s, 42.5
  end

  def test_schema_definition_accept_boolean
    s = Respect::Schema.define do |s|
      s.boolean equal_to: true
    end
    assert_schema_validate s, "true"
    assert_schema_validate s, true
  end

  def test_schema_definition_accept_boolean_with_no_option
    s = Respect::Schema.define do |s|
      s.boolean
    end
    assert_schema_validate s, true
    assert_schema_validate s, false
  end

  def test_schema_definition_accept_array
    s = Respect::Schema.define do |s|
      s.array do |s|
        s.integer
      end
    end
    assert_schema_validate s, [1]
  end

  def test_schema_definition_accept_array_with_no_option
    s = Respect::Schema.define do |s|
      s.array
    end
    assert_schema_validate s, [1]
  end

  def test_can_factor_object_definition
    object_def = Proc.new do |s|
      s.numeric "n", equal_to: 42
    end
    s1 = Respect::ObjectSchema.define do |s|
      s.eval(&object_def)
    end
    s2 = Respect::ObjectSchema.define do |s|
      s.eval(&object_def)
    end
    assert_schema_validate s1, { "n" => 42 }
    assert_schema_validate s2, { "n" => 42 }
  end

  def test_can_factor_array_definition
    array_def = Proc.new do |s|
      s.numeric equal_to: 42
    end
    s1 = Respect::ArraySchema.define do |s|
      s.eval(&array_def)
    end
    s2 = Respect::ArraySchema.define do |s|
      s.eval(&array_def)
    end
    assert_schema_validate s1, [ 42 ]
    assert_schema_validate s2, [ 42 ]
  end

  def test_can_factor_options
    options = { equal_to: 42 }
    s = Respect::ObjectSchema.define do |s|
      s.integer "int", options
      s.numeric "num", options
    end
    assert_schema_validate s, { "int" => 42, "num" => 42.0 }
  end

  def test_method_missing_is_raised_in_dsl
    for_each_context do |s|
      assert_raise(NoMethodError,
        "unknown method raises NoMethodError in #{s.target.class}") do
        s.unknown_method
      end
    end
  end

  def test_can_use_object_methods_in_dsl_evaluator
    for_each_context do |s|
      assert_nothing_raised("can call Object method from DSL evaluator in #{s.target.class}") do
        s.class
      end
    end
  end

  def test_cannot_use_kernel_methods_in_dsl_evaluator
    for_each_context do |s|
      assert_nothing_raised("can call Kernel method from DSL evaluator in #{s.target.class}") do
        s.send(:String, "foo")
      end
    end
  end

  def test_helper_can_use_kernel_features
    for_each_context do |s|
      assert_nothing_raised("call to Kernel method works in #{s.target.class}") do
        s.call_to_kernel
      end
    end
  end

  def test_helper_can_use_object_features
    for_each_context do |s|
      assert_nothing_raised("call to Object method works in #{s.target.class}") do
        s.call_to_object
      end
    end
  end

  def test_dsl_accept_basic_statements_with_no_option
    BASIC_STATEMENTS_LIST.each do |statement|
      for_each_context do |s|
        assert_nothing_raised("'#{statement}' method accepted in #{s.target.class}") do
          send_statement_in_context(s, statement, "fake name")
        end
      end
    end
  end

  def test_can_extend_dsl_with_custom_module
    # See DSL extension module defined in test_helper.rb.
    s = Respect::ObjectSchema.define do |s|
      s.id
      s.id "table_id"
      s.array "array" do |s|
        s.id
      end
    end
    assert_schema_validate s, { "id" => 42, "table_id" => 12, "array" => [ 1, 2 ]}
    assert_schema_invalidate s, { "id" => 42, "table_id" => 12, "array" => [ -1, 2 ]}
    assert_schema_invalidate s, { "id" => 0, "table_id" => 12, "array" => [ 1, 2 ]}
    assert_schema_invalidate s, { "id" => 42, "table_id" => 12, "array" => [ 1, -2 ]}
    assert_schema_invalidate s, { "id" => 42, "table_id" => 0, "array" => [ 1, 2 ]}
  end

  def test_can_convert_doc_to_custom_type
    # See DSL extension module defined in test_helper.rb.
    s = Respect::ObjectSchema.define do |s|
      s.point "origin"
      s.array "polygon" do |s|
        s.point
      end
    end
    # Check validation works.
    assert_schema_validate s, { "origin" => { "x" => 1.0, "y" => 0.0 },
        "polygon" => [ { "x" => 2.0, "y" => 3.0 } ] }
    assert_schema_invalidate s, { "origin" => { "x" => 1.0 },
        "polygon" => [ { "x" => 2.0, "y" => 3.0 } ] }
    assert_schema_invalidate s, { "origin" => { "x" => 1.0, "y" => 0.0 },
        "polygon" => [ { "x" => 2.0 } ] }
    # Check conversion works.
    doc = { "origin" => { "x" => 1.0, "y" => 0.0 }, "polygon" => [ { "x" => 2.0, "y" => 3.0 } ] }
    assert_schema_validate s, doc
    assert_equal({ "origin" => Point.new(1.0, 0.0), "polygon" => [ Point.new(2.0, 3.0) ]},
      s.sanitized_doc)
  end

  def test_format_helper_statement_create_string_schema
    FORMAT_HELPER_STATEMENTS_LIST.each do |statement|
      for_each_context do |s|
        schema = send_statement_in_context(s, statement, "an_statement", equal_to: "expected_value")
        assert schema.is_a?(Respect::StringSchema), "is a StringSchema for #{statement} in #{s.target.class}"
        assert_equal statement, schema.options[:format], "format is :#{statement} in #{s.target.class}"
        assert_equal "expected_value", schema.options[:equal_to], "equal_to works for #{statement} in #{s.target.class}"
      end
    end
  end

  def test_statement_return_created_schema
    BASIC_STATEMENTS_LIST.each do |statement|
      for_each_context do |s|
        schema = send_statement_in_context(s, statement, "fake name")
        assert schema.is_a?(Respect::Schema), "'#{statement}' returns a schema in #{s.target.class}"
      end
    end
  end

  def test_uri_statement_create_uri_schema
    for_each_context do |s|
      schema = send_statement_in_context(s, :uri, "an_uri", equal_to: "expected_value")
      assert schema.is_a?(Respect::URISchema), "is a URISchema in #{s.target.class}"
      assert_equal "expected_value", schema.options[:equal_to], "equal_to works in #{s.target.class}"
    end
  end

  def test_regexp_statement_create_regexp_schema
    for_each_context do |s|
      schema = send_statement_in_context(s, :regexp, "a_regexp", equal_to: "expected_value")
      assert schema.is_a?(Respect::RegexpSchema), "is a RegexpSchema in #{s.target.class}"
      assert_equal "expected_value", schema.options[:equal_to], "equal_to works in #{s.target.class}"
    end
  end

  def test_datetime_statement_create_datetime_schema
    for_each_context do |s|
      schema = send_statement_in_context(s, :datetime, "a_datetime", equal_to: "expected_value")
      assert schema.is_a?(Respect::DatetimeSchema), "is a DatetimeSchema in #{s.target.class}"
      assert_equal "expected_value", schema.options[:equal_to], "equal_to works in #{s.target.class}"
    end
  end

  def test_ip_addr_statement_create_ipaddr_schema
    for_each_context do |s|
      schema = send_statement_in_context(s, :ip_addr, "a_ip_addr", equal_to: "expected_value")
      assert schema.is_a?(Respect::IPAddrSchema), "is a IPAddrSchema in #{s.target.class}"
      assert_equal "expected_value", schema.options[:equal_to], "equal_to works in #{s.target.class}"
    end
  end

  def test_ipv4_addr_statement_create_ipv4addr_schema
    for_each_context do |s|
      schema = send_statement_in_context(s, :ipv4_addr, "a_ipv4_addr", equal_to: "expected_value")
      assert schema.is_a?(Respect::Ipv4AddrSchema), "is a Ipv4AddrSchema in #{s.target.class}"
      assert_equal "expected_value", schema.options[:equal_to], "equal_to works in #{s.target.class}"
    end
  end

  def test_ipv6_addr_statement_create_ipv6addr_schema
    for_each_context do |s|
      schema = send_statement_in_context(s, :ipv6_addr, "a_ipv6_addr", equal_to: "expected_value")
      assert schema.is_a?(Respect::Ipv6AddrSchema), "is a Ipv6AddrSchema in #{s.target.class}"
      assert_equal "expected_value", schema.options[:equal_to], "equal_to works in #{s.target.class}"
    end
  end

  def test_utc_time_statement_create_utc_time_schema
    for_each_context do |s|
      schema = send_statement_in_context(s, :utc_time, "a_utc_time", equal_to: "expected_value")
      assert schema.is_a?(Respect::UTCTimeSchema), "is a UTCTimeSchema in #{s.target.class}"
      assert_equal "expected_value", schema.options[:equal_to], "equal_to works in #{s.target.class}"
    end
  end

  def test_statements_have_doc_option
    BASIC_STATEMENTS_LIST.each do |statement|
      for_each_context do |s|
        schema = send_statement_in_context(s, statement, "a_name", doc: @doc)
        assert_equal @title, schema.title, "title set by #{statement} in #{s.target.class}"
        assert_equal @description, schema.description, "description set by #{statement} in #{s.target.class}"
        assert_equal @doc, schema.doc, "doc set by #{statement} in #{s.target.class}"
      end
    end
  end

  def test_doc_statement_assign_every_statements
    BASIC_STATEMENTS_LIST.each do |statement|
      for_each_context do |s|
        title = "#@title for '#{statement}' in #{s.target.class}"
        description = "#@description for '#{statement}' in #{s.target.class}"
        doc = "#{title}\n\n#{description}"
        s.doc doc
        schema = send_statement_in_context(s, statement, "a_name")
        assert_equal title, schema.title, "title set by #{statement} in #{s.target.class}"
        assert_equal description, schema.description, "description set by #{statement} in #{s.target.class}"
        assert_equal doc, schema.doc, "doc set by #{statement} in #{s.target.class}"
      end
    end
  end

  def test_abstract_schema_class_have_no_dynamic_statement
    for_each_context do |s|
      assert_raise(NoMethodError,
        "abstract class have no dynamic statement in #{s.target.class}") do
        s.__send__(:composite)
      end
    end
  end

  def test_eval_in_fake_name_proxy
    for_each_context do |s|
      assert(s.__id__ != s.target.__id__, "proxy present in #{s.target.class}")
      assert(s.class == s.target.class, "proxy present in #{s.target.class}")
    end
  end


  private

  # Run the given block in each context of the DSL.
  # It passes the context as first argument to the block.
  def for_each_context(&block)
    # In root context.
    Respect::Schema.define {|s| instance_exec(s, &block) }
    # In all contexts.
    {
      :object => [
        nil,
        :extra,
      ],
      :array => [
        nil,
        :items,
        :extra_items,
      ]
    }.each do |ctxt, sub_ctxts|
      sub_ctxts.each do |sub_ctxt|
        Respect::Schema.define do |s|
          s.__send__(ctxt) do |s|
            if sub_ctxt
              s.__send__(sub_ctxt) do |s|
                instance_exec(s, &block)
              end
            else
              instance_exec(s, &block)
            end
          end
        end
      end
    end
  end

  # Send the given _statement_ to the given _dsl_def_ context. Name is passed
  # if the context accept a name. All the rest of the arguments and the block
  # are always passed.
  def send_statement_in_context(dsl_def, statement, name, *args, &block)
    if dsl_def.target.class.accept_name?
      dsl_def.__send__(statement, name, *args, &block)
    else
      dsl_def.__send__(statement, *args, &block)
    end
  end

end
