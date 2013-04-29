module Respect
  class Org3Dumper

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
          if Org3Dumper::FORMAT_TYPE_MAP.has_key?(v)
            translation_value = Org3Dumper::FORMAT_TYPE_MAP[v]
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

    def dump(output = nil)
      @output = output
      @output ||= Hash.new
      @output = dump_schema(@schema, ignore: [:required])
      @output
    end

    attr_reader :output

    def dump_schema(schema, *args)
      dispatch_dump_schema(schema.class, schema, *args)
    end

    def dispatch_dump_schema(klass, schema, *args)
      symbol = "dump_schema_for_#{klass.command_name}"
      if respond_to? symbol
        send(symbol, schema, *args)
      else
        if klass == Schema
          raise NoMethoderror, "undefined method '#{symbol}' for schema class #{schema.class}"
        else
          dispatch_dump_schema(klass.superclass, schema, *args)
        end
      end
    end

    def dump_schema_for_schema(schema, params = {})
      return nil if !schema.documented?
      h = {}
      h['type'] = dump_command_name(schema)
      # Dump generic options.
      schema.options.each do |opt, opt_value|
        next if params[:ignore] && params[:ignore].include?(opt)
        if Org3Dumper::OPTION_MAP.has_key?(opt)
          Org3Dumper::OPTION_MAP[opt].each do |k, v|
            if v == :option_value
              h[k] = (opt_value.is_a?(Numeric) ? opt_value : opt_value.dup)
            elsif v.is_a?(Proc)
              result = schema.instance_exec(opt_value, &v)
              h[k] = result unless result.nil?
            else
              h[k] = v
            end
          end
        end
      end
      h.merge!(dump_options(schema))
      # Dump documentation
      h["title"] = schema.title if schema.title
      h["description"] = schema.description if schema.description
      h
    end

    def dump_schema_for_object(schema, params = {})
      h = dump_schema_for_schema(schema, params)
      return nil if h.nil?
      props = {}
      pattern_props = {}
      additional_props = {}
      schema.properties.each do |prop, schema|
        if prop.is_a?(Regexp)
          if schema.optional?
            # FIXME(Nicolas Despres): Find a better warning reporting system.
            warn "pattern properties cannot be optional in json-schema.org draft v3"
          else
            # FIXME(Nicolas Despres): What do we do with regexp options such as 'i'?
            schema_dump = dump_schema(schema)
            pattern_props[prop.source] = schema_dump if schema_dump
          end
        else
          if schema.optional?
            schema_dump = dump_schema(schema)
            additional_props[prop.to_s] = schema_dump if schema_dump
          else
            schema_dump = dump_schema(schema)
            props[prop.to_s] = schema_dump if schema_dump
          end
        end
      end
      h['properties'] = props unless props.empty?
      h['patternProperties'] = pattern_props unless pattern_props.empty?
      if additional_props.empty?
        if schema.options[:strict]
          h['additionalProperties'] = false
        end
      else
        h['additionalProperties'] = additional_props
      end
      h
    end

    def dump_schema_for_array(schema, params = {})
      h = dump_schema_for_schema(schema, params)
      return nil if h.nil?
      if schema.item
        h['items'] = dump_schema(schema.item, ignore: [:required])
      else
        if schema.items && !schema.items.empty?
          h['items'] = schema.items.map do |x|
            dump_schema(x, ignore: [:required])
          end
        end
        if schema.extra_items && !schema.extra_items.empty?
          h['additionalItems'] = schema.extra_items.map do |x|
            dump_schema(x, ignore: [:required])
          end
        end
      end
      h
    end

    def dump_schema_for_composite(schema, params = {})
      dump_schema(schema.schema, params)
    end

    def dump_command_name(schema, *args)
      dispatch_dump_command_name(schema.class, schema, *args)
    end

    def dispatch_dump_command_name(klass, schema, *args)
      symbol = "dump_command_name_for_#{klass.command_name}"
      if respond_to? symbol
        send(symbol, schema, *args)
      else
        if klass == Schema
          raise NoMethoderror, "undefined method '#{symbol}' for schema class #{schema.class}"
        else
          dispatch_dump_command_name(klass.superclass, schema, *args)
        end
      end
    end

    def dump_command_name_for_schema(schema)
      schema.class.command_name
    end

    def dump_command_name_for_numeric(schema)
      "number"
    end

    def dump_command_name_for_integer(schema)
      "integer"
    end

    def dump_command_name_for_string(schema)
      "string"
    end

    def dump_options(schema, *args)
      dispatch_dump_options(schema.class, schema, *args)
    end

    def dispatch_dump_options(klass, schema, *args)
      symbol = "dump_options_for_#{klass.command_name}"
      if respond_to? symbol
        send(symbol, schema, *args)
      else
        if klass == Schema
          raise NoMethoderror, "undefined method '#{symbol}' for schema class #{schema.class}"
        else
          dispatch_dump_options(klass.superclass, schema, *args)
        end
      end
    end

    def dump_options_for_schema(schema)
      {}
    end

    def dump_options_for_uri(schema)
      { "format" => "uri" }
    end

    def dump_options_for_regexp(schema)
      { "format" => "regex" }
    end

    def dump_options_for_datetime(schema)
      { "format" => "date-time" }
    end

    def dump_options_for_ipv4_addr(schema)
      { "format" => "ip-address" }
    end

    def dump_options_for_ipv6_addr(schema)
      { "format" => "ipv6" }
    end

  end

end
