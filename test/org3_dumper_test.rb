require "test_helper"

class Org3Dumper < Test::Unit::TestCase
  def test_dump_basic_types_commands_with_no_options
    [
      :integer,
      :string,
      :any,
      :boolean,
      :null,
    ].each do |command|
      s = Respect::Schema.define do |s|
        s.__send__(command)
      end
      a = Respect::Org3Dumper.new(s).dump
      e = {
        "type" => command.to_s,
      }
      assert_equal e, a, "dump command #{command}"
    end
  end

  def test_numeric_and_float_schema_are_number_type
    {
      :NumericSchema => "number",
      :FloatSchema => "number",
    }.each do |schema_class, type|
      s = Respect.const_get(schema_class).new
      a = Respect::Org3Dumper.new(s).dump
      e = { "type" => type }
      assert_equal e, a, "dump schema #{schema_class}"
    end
  end

  def test_dump_extended_simple_schema
    {
      :UriSchema => "uri",
      :RegexpSchema => "regex",
      :DatetimeSchema => "date-time",
      :Ipv4AddrSchema => "ip-address",
      :Ipv6AddrSchema => "ipv6",
    }.each do |schema_class, format|
      s = Respect.const_get(schema_class).new
      a = Respect::Org3Dumper.new(s).dump
      e = { "type" => "string", "format" => format}
      assert_equal e, a, "dump schema #{schema_class}"
    end
  end

  # TODO(Nicolas Despres): Test IpAddrSchema warn that it can not be dumped.
  # TODO(Nicolas Despres): Test UtcTimeSchema warn that it can not be dumped.

  def test_dump_helper_command
    {
      :phone_number => "phone",
      :hostname => "host-name",
      :email => "email",
    }.each do |command, format|
      s = Respect::Schema.define do |s|
        s.__send__(command)
      end
      a = Respect::Org3Dumper.new(s).dump
      e = {
        "type" => "string",
        "format" => format,
      }
      assert_equal e, a, "dump command #{command}"
    end
  end

  def test_dump_object_properties
    s = Respect::ObjectSchema.define do |s|
      s.integer "i"
      s.string "s"
      s.float "f"
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "object",
      "properties" => {
        "i" => {
          "type" => "integer",
          "required" => true,
        },
        "s" => {
          "type" => "string",
          "required" => true,
        },
        "f" => {
          "type" => "number",
          "required" => true,
        },
      }
    }
    assert_equal e, a
  end

  def test_dump_object_optional_properties
    s = Respect::ObjectSchema.define do |s|
      s.integer "i"
      s.string "s"
      s.optionals do |s|
        s.string "o_s"
        s.float "o_f"
      end
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "object",
      "properties" => {
        "i" => {
          "type" => "integer",
          "required" => true,
        },
        "s" => {
          "type" => "string",
          "required" => true,
        },
      },
      "additionalProperties" => {
        "o_s" => { "type" => "string" },
        "o_f" => { "type" => "number" },
      },
    }
    assert_equal e, a
  end

  def test_dump_object_pattern_properties
    s = Respect::ObjectSchema.define do |s|
      s.integer "i"
      s.string /s.*t/
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "object",
      "properties" => {
        "i" => {
          "type" => "integer",
          "required" => true,
        },
      },
      "patternProperties" => {
        "s.*t" => {
          "type" => "string",
          "required" => true,
        },
      },
    }
    assert_equal e, a
  end

  def test_dump_nested_object
    s = Respect::ObjectSchema.define do |s|
      s.object "o1" do |s|
        s.object "o2" do |s|
          s.object "o3" do |s|
            s.integer "i"
          end
        end
      end
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "object",
      "properties" => {
        "o1" => {
          "type" => "object",
          "required" => true,
          "properties" => {
            "o2" => {
              "type" => "object",
              "required" => true,
              "properties" => {
                "o3" => {
                  "type" => "object",
                  "required" => true,
                  "properties" => {
                    "i" => {
                      "type" => "integer",
                      "required" => true,
                    },
                  },
                },
              },
            },
          },
        },
      },
    }
    assert_equal e, a
  end

  def test_dump_nested_pattern_properties
    s = Respect::ObjectSchema.define do |s|
      s.object /o1/ do |s|
        s.object /o2/ do |s|
          s.object /o3/ do |s|
            s.integer "i"
          end
        end
      end
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "object",
      "patternProperties" => {
        "o1" => {
          "type" => "object",
          "required" => true,
          "patternProperties" => {
            "o2" => {
              "type" => "object",
              "required" => true,
              "patternProperties" => {
                "o3" => {
                  "type" => "object",
                  "required" => true,
                  "properties" => {
                    "i" => {
                      "type" => "integer",
                      "required" => true,
                    },
                  },
                },
              },
            },
          },
        },
      },
    }
    assert_equal e, a
  end

  def test_dump_nested_optionals_properties
    s = Respect::ObjectSchema.define do |s|
      s.optionals do |s|
        s.object "o1" do |s|
          s.optionals do |s|
            s.object "o2" do |s|
              s.optionals do |s|
                s.object "o3" do |s|
                  s.integer "i"
                end
              end
            end
          end
        end
      end
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "object",
      "additionalProperties" => {
        "o1" => {
          "type" => "object",
          "additionalProperties" => {
            "o2" => {
              "type" => "object",
              "additionalProperties" => {
                "o3" => {
                  "type" => "object",
                  "properties" => {
                    "i" => {
                      "type" => "integer",
                      "required" => true,
                    },
                  },
                },
              },
            },
          },
        },
      },
    }
    assert_equal e, a
  end

  def test_do_not_dump_empty_object_properties
    s = Respect::ObjectSchema.define do |s|
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "object",
    }
    assert_equal e, a
  end

  def test_do_not_dump_empty_object_optional_properties
    s = Respect::ObjectSchema.define do |s|
      s.optionals do |s|
      end
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "object",
    }
    assert_equal e, a
  end

  def test_dump_object_in_strict_mode
    s = Respect::ObjectSchema.define strict: true do |s|
      s.integer "i"
      s.string /s/
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "object",
      "properties" => { "i" => { "type" => "integer", "required" => true } },
      "patternProperties" => { "s" => { "type" => "string", "required" => true } },
      "additionalProperties" => false,
    }
    assert_equal e, a
  end

  def test_do_not_dump_nodoc_object_properties
    s = Respect::ObjectSchema.define do |s|
      s.integer "enabled"
      s.integer "nodoc", doc: false
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "object",
      "properties" => { "enabled" => { "type" => "integer", "required" => true } },
    }
    assert_equal e, a
  end

  def test_do_not_dump_nodoc_object_optional_properties
    s = Respect::ObjectSchema.define do |s|
      s.optionals do |s|
        s.integer "enabled"
        s.integer "nodoc", doc: false
      end
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "object",
      "additionalProperties" => { "enabled" => { "type" => "integer" } },
    }
    assert_equal e, a
  end

  def test_do_not_dump_nodoc_object_pattern_properties
    s = Respect::ObjectSchema.define do |s|
      s.integer /enabled/
      s.integer /nodoc/, doc: false
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "object",
      "patternProperties" => { "enabled" => { "type" => "integer", "required" => true } },
    }
    assert_equal e, a
  end

  def test_dump_array_item
    s = Respect::ArraySchema.define do |s|
      s.integer
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "array",
      "items" => {
        "type" => "integer",
      },
    }
    assert_equal e, a
  end

  def test_dump_array_items
    s = Respect::ArraySchema.define do |s|
      s.items do |s|
        s.integer
        s.string
        s.float
      end
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "array",
      "items" => [
        { "type" => "integer" },
        { "type" => "string" },
        { "type" => "number" },
      ],
    }
    assert_equal e, a
  end

  def test_dump_array_items_and_extra_items
    s = Respect::ArraySchema.define do |s|
      s.items do |s|
        s.integer
      end
      s.extra_items do |s|
        s.string
        s.float
      end
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "array",
      "items" => [
        { "type" => "integer" },
      ],
      "additionalItems" => [
        { "type" => "string" },
        { "type" => "number" },
      ],
    }
    assert_equal e, a
  end

  def test_dump_array_extra_items
    s = Respect::ArraySchema.define do |s|
      s.extra_items do |s|
        s.string
        s.float
      end
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "array",
      "additionalItems" => [
        { "type" => "string" },
        { "type" => "number" },
      ],
    }
    assert_equal e, a
  end

  def test_dump_nested_array_item
    s = Respect::ArraySchema.define do |s|
      s.array do |s|
        s.array do |s|
          s.integer
        end
      end
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "array",
      "items" => {
        "type" => "array",
        "items" => {
          "type" => "array",
          "items" => {
            "type" => "integer",
          },
        },
      },
    }
    assert_equal e, a
  end

  def test_dump_nested_array_items
    s = Respect::ArraySchema.define do |s|
      s.items do |s|
        s.array do |s|
          s.items do |s|
            s.array do |s|
              s.items do |s|
                s.integer
                s.string
              end
            end
            s.integer
            s.string
          end
        end
        s.integer
        s.string
        s.float
      end
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "array",
      "items" => [
        {
          "type" => "array",
          "items" => [
            {
              "type" => "array",
              "items" => [
                { "type" => "integer" },
                { "type" => "string" },
              ],
            },
            { "type" => "integer" },
            { "type" => "string" },
          ],
        },
        { "type" => "integer" },
        { "type" => "string" },
        { "type" => "number" },
      ],
    }
    assert_equal e, a
  end

  def test_dump_nested_array_extra_items
    s = Respect::ArraySchema.define do |s|
      s.extra_items do |s|
        s.array do |s|
          s.extra_items do |s|
            s.array do |s|
              s.extra_items do |s|
                s.integer
                s.string
              end
            end
            s.integer
            s.string
          end
        end
        s.integer
        s.string
        s.float
      end
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "array",
      "additionalItems" => [
        {
          "type" => "array",
          "additionalItems" => [
            {
              "type" => "array",
              "additionalItems" => [
                { "type" => "integer" },
                { "type" => "string" },
              ],
            },
            { "type" => "integer" },
            { "type" => "string" },
          ],
        },
        { "type" => "integer" },
        { "type" => "string" },
        { "type" => "number" },
      ],
    }
    assert_equal e, a
  end

  def test_do_not_dump_empty_array_item
    s = Respect::ArraySchema.define do |s|
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "array",
    }
    assert_equal e, a
  end

  def test_do_not_dump_empty_array_items
    s = Respect::ArraySchema.define do |s|
      s.items do |s|
      end
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "array",
    }
    assert_equal e, a
  end

  def test_do_not_dump_empty_array_extra_items
    s = Respect::ArraySchema.define do |s|
      s.extra_items do |s|
      end
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "array",
    }
    assert_equal e, a
  end

  def test_dump_option_required
    s = Respect::ObjectSchema.define do |s|
      s.integer "required_i"
      s.integer "default_i", default: 42
      s.integer "non_required_i", required: false
      s.optionals do |s|
        s.integer "optional_i"
      end
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "object",
      "properties" => {
        "required_i" => { "type" => "integer", "required" => true },
      },
      "additionalProperties" => {
        "default_i" => { "type" => "integer", "default" => 42 },
        "non_required_i" => { "type" => "integer" },
        "optional_i" => { "type" => "integer" },
      },
    }
    assert_equal e, a
  end

  def test_dump_integer_single_option_with_trivial_translation
    {
      integer: {
        divisible_by: { value: 2, trans: { "divisibleBy" => 2 } },
        multiple_of: { value: 2, trans: { "divisibleBy" => 2 } },
        in: { value: [ 2, 3, 4 ], trans: { "enum" => [ 2, 3, 4 ] } },
        equal_to: { value: 2, trans: { "enum" => [ 2 ] } },
        greater_than: { value: 2, trans: { "minimum" => 2, "exclusiveMinimum" => true } },
        greater_than_or_equal_to: { value: 2, trans: { "minimum" => 2 } },
        less_than: { value: 2, trans: { "maximum" => 2, "exclusiveMaximum" => true } },
        less_than_or_equal_to: { value: 2, trans: { "maximum" => 2 } },
      },
      string: {
        match: { value: /s.*t/, trans: { "pattern" => "s.*t" } },
        min_length: { value: 42, trans: { "minLength" => 42 } },
        max_length: { value: 42, trans: { "maxLength" => 42 } },
      },
      array: {
        uniq: { value: true, trans: { "uniqueItems" => true } },
        min_size: { value: 42, trans: { "minItems" => 42 } },
        max_size: { value: 42, trans: { "maxItems" => 42 } },
      },
    }.each do |command, options|
      options.each do |opt, params|
        s = Respect::Schema.define do |s|
          s.__send__(command, { opt => params[:value] })
        end
        a = Respect::Org3Dumper.new(s).dump
        e = { "type" => command.to_s }.merge(params[:trans])
        assert_equal e, a, "dump option #{opt} for command #{command}"
        # Test option value are not shared between the hash and the schema.
        params[:trans].each do |k, v|
          unless v.is_a?(Numeric) || v.is_a?(TrueClass) || v.is_a?(FalseClass)
            assert(s.options[opt].object_id != a[k].object_id,
              "non shared option value for option '#{opt}' for command '#{command}'")
          end
        end
      end
    end
  end

  def test_dump_option_format
    {
      email: 'email',
      uri: 'uri',
      regexp: 'regex',
      datetime: 'date-time',
      ipv4_addr: 'ip-address',
      phone_number: 'phone',
      ipv6_addr: 'ipv6',
      hostname: 'host-name',
    }.each do |format, type|
      s = Respect::Schema.define do |s|
        s.string format: format
      end
      a = Respect::Org3Dumper.new(s).dump
      e = {
        "type" => "string",
        "format" => type,
      }
      assert_equal e, a, "dump format #{format}"
    end
  end

  # FIXME(Nicolas Despres): Test ip_addr format warn that it cannot be dumped

  def test_dump_documentation
    [
      { doc: "a title\n\na description",
        expected: { "title" => "a title", "description" => "a description" },
        message: "complete documentation",
      },
      { doc: "a long ... \n ... description",
        expected: { "description" => "a long ... \n ... description" },
        message: "documentation with no title",
      },
      { doc: "a title",
        expected: { "title" => "a title" },
        message: "documentation with no description",
      },
    ].each do |data|
      s = Respect::Schema.define do |s|
        s.doc data[:doc]
        s.integer
      end
      a = Respect::Org3Dumper.new(s).dump
      e = { "type" => "integer" }.merge(data[:expected])
      assert_equal e, a, data[:message]
    end
  end

  def test_no_dump_for_nodoc
    BASIC_COMMANDS_LIST.each do |command|
      s = Respect::Schema.define do |s|
        s.__send__(command, doc: false)
      end
      assert_nil Respect::Org3Dumper.new(s).dump
    end
  end

  def test_no_dump_for_non_empty_object
    s = Respect::Schema.define do |s|
      s.object doc: false do |s|
        s.integer "i"
        s.string "s"
      end
    end
    assert_nil Respect::Org3Dumper.new(s).dump
  end

  def test_no_dump_for_non_empty_array
    s = Respect::Schema.define do |s|
      s.array doc: false do |s|
        s.integer
      end
    end
    assert_nil Respect::Org3Dumper.new(s).dump
  end

  def test_dump_composite_schema
    s = Respect::ObjectSchema.define do |s|
      s.point "origin"
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "object",
      "properties" => {
        "origin" => {
          "type" => "object",
          "required" => true,
          "properties" => {
            "x" => { "type" => "number", "required" => true },
            "y" => { "type" => "number", "required" => true },
          }
        }
      }
    }
    assert_equal e, a
  end

  def test_dump_nested_composite_schema
    s = Respect::ObjectSchema.define do |s|
      s.circle "area"
    end
    a = Respect::Org3Dumper.new(s).dump
    e = {
      "type" => "object",
      "properties" => {
        "area" => {
          "type" => "object",
          "required" => true,
          "properties" => {
            "center" => {
              "type" => "object",
              "required" => true,
              "properties" => {
                "x" => { "type" => "number", "required" => true },
                "y" => { "type" => "number", "required" => true },
              }
            },
            "radius" => {
              "type" => "number",
              "required" => true,
              "minimum" => 0.0,
              "exclusiveMinimum" => true
            }
          }
        }
      }
    }
    assert_equal e, a
  end

  def test_dump_no_doc
  end

end
