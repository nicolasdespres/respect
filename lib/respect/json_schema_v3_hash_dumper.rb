module Respect
  class JsonSchemaV3HashDumper

    # Translation table mapping DSL options with json-schema.org v3
    # options. The associated hash is injected in the output. Values
    # are interpreted as follow:
    # - :option_value represent the option value passed to the DSL option parameter.
    # - a proc is called with the option value as argument and the result is used
    #   as the value for the output key if it is not nil.
    # - other value are inserted verbatim.
    OPTION_MAP = {
      divisible_by: { 'divisibleBy' => :option_value },
      multiple_of: { 'divisibleBy' => :option_value },
      in: { 'enum' => :option_value },
      equal_to: { 'enum' => Proc.new{|v| [v] } },
      min_length: { 'minLength' => :option_value },
      max_length: { 'maxLength' => :option_value },
      min_size: { 'minItems' => :option_value },
      max_size: { 'maxItems' => :option_value },
      format: { 'format' => Proc.new do |v|
          if JsonSchemaV3HashDumper::FORMAT_TYPE_MAP.has_key?(v)
            translation_value = JsonSchemaV3HashDumper::FORMAT_TYPE_MAP[v]
            translation_value unless translation_value.nil?
          else
            v.to_s
          end
        end
      },
      greater_than: { "minimum" => :option_value, "exclusiveMinimum" => true },
      greater_than_or_equal_to: { "minimum" => :option_value },
      less_than: { "maximum" => :option_value, "exclusiveMaximum" => true },
      less_than_or_equal_to: { "maximum" => :option_value },
      match: { "pattern" => Proc.new{|v| v.source } },
      uniq: { "uniqueItems" => Proc.new{|v| v if v } },
      default: { "default" => Proc.new{|v| v unless v.nil? } },
      required: { "required" => Proc.new{|v| true if required? } },
    }.freeze

    # Only non direct translation are listed here. If one of our validator
    # does not translate it gets the nil value.
    FORMAT_TYPE_MAP = {
      regexp: 'regex',
      datetime: 'date-time',
      ipv4_addr: 'ip-address',
      phone_number: 'phone',
      ipv6_addr: 'ipv6',
      ip_addr: nil,
      hostname: 'host-name',
    }.freeze

    def initialize(schema)
      @schema = schema
    end

    def dump
      @schema.dump_as_json_schema_v3_hash(ignore: [:required])
    end

  end # class JsonSchemaV3HashDumper

  class Schema
    def dump_as_json_schema_v3_hash(params = {})
      h = {}
      h['type'] = dump_command_name_as_json_schema_v3_hash
      # Dump generic options.
      options.each do |opt, opt_value|
        next if params[:ignore] && params[:ignore].include?(opt)
        if JsonSchemaV3HashDumper::OPTION_MAP.has_key?(opt)
          JsonSchemaV3HashDumper::OPTION_MAP[opt].each do |k, v|
            if v == :option_value
              h[k] = (opt_value.is_a?(Numeric) ? opt_value : opt_value.dup)
            elsif v.is_a?(Proc)
              result = self.instance_exec(opt_value, &v)
              h[k] = result unless result.nil?
            else
              h[k] = v
            end
          end
        end
      end
      h.merge!(dump_options_as_json_schema_v3_hash)
      # Dump documentation
      h["title"] = title if title
      h["description"] = description if description
      h
    end

    def dump_command_name_as_json_schema_v3_hash
      self.class.command_name
    end

    def dump_options_as_json_schema_v3_hash
      {}
    end

  end

  class ObjectSchema < Schema
    def dump_as_json_schema_v3_hash(params = {})
      h = super
      props = {}
      pattern_props = {}
      additional_props = {}
      @properties.each do |prop, schema|
        if prop.is_a?(Regexp)
          if schema.optional?
            # FIXME(Nicolas Despres): Find a better warning reporting system.
            warn "pattern properties cannot be optional in json-schema.org draft v3"
          else
            # FIXME(Nicolas Despres): What do we do with regexp options such as 'i'?
            pattern_props[prop.source] = schema.dump_as_json_schema_v3_hash
          end
        else
          if schema.optional?
            additional_props[prop.to_s] = schema.dump_as_json_schema_v3_hash
          else
            props[prop.to_s] = schema.dump_as_json_schema_v3_hash
          end
        end
      end
      h['properties'] = props unless props.empty?
      h['patternProperties'] = pattern_props unless pattern_props.empty?
      if additional_props.empty?
        if options[:strict]
          h['additionalProperties'] = false
        end
      else
        h['additionalProperties'] = additional_props
      end
      h
    end
  end

  class ArraySchema < Schema
    def dump_as_json_schema_v3_hash(params = {})
      h = super
      if @item
        h['items'] = @item.dump_as_json_schema_v3_hash(ignore: [:required])
      else
        if @items && !@items.empty?
          h['items'] = @items.map do |x|
            x.dump_as_json_schema_v3_hash(ignore: [:required])
          end
        end
        if @extra_items && !@extra_items.empty?
          h['additionalItems'] = @extra_items.map do |x|
            x.dump_as_json_schema_v3_hash(ignore: [:required])
          end
        end
      end
      h
    end
  end

  class NumericSchema < Schema
    def dump_command_name_as_json_schema_v3_hash
      "number"
    end
  end

  class IntegerSchema < NumericSchema
    def dump_command_name_as_json_schema_v3_hash
      "integer"
    end
  end

  class StringSchema < Schema
    def dump_command_name_as_json_schema_v3_hash
      "string"
    end
  end

  class UriSchema < StringSchema
    def dump_options_as_json_schema_v3_hash
      { "format" => "uri" }
    end
  end

  class RegexpSchema < StringSchema
    def dump_options_as_json_schema_v3_hash
      { "format" => "regex" }
    end
  end

  class DatetimeSchema < StringSchema
    def dump_options_as_json_schema_v3_hash
      { "format" => "date-time" }
    end
  end

  class Ipv4AddrSchema < StringSchema
    def dump_options_as_json_schema_v3_hash
      { "format" => "ip-address" }
    end
  end

  class Ipv6AddrSchema < StringSchema
    def dump_options_as_json_schema_v3_hash
      { "format" => "ipv6" }
    end
  end

  class CompositeSchema < Schema
    def dump_as_json_schema_v3_hash(params = {})
      @schema.dump_as_json_schema_v3_hash(params)
    end
  end

end # module Respect
