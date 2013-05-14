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
      min_size: { 'minItems' => :option_value },
      max_size: { 'maxItems' => :option_value },
      uniq: { "uniqueItems" => Proc.new{|v| v if v } },
      default: { "default" => Proc.new{|v| v unless v.nil? } },
      required: { "required" => Proc.new{|v| true if required? } },
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
      dispatch("dump_schema", schema.class, schema, *args)
    end

    def dump_schema_for_schema(schema, params = {})
      return nil if !schema.documented?
      h = {}
      h['type'] = dump_command_name(schema)
      # Dump generic options.
      schema.options.each do |opt, opt_value|
        next if params[:ignore] && params[:ignore].include?(opt)
        if validator_class = Respect.validator_for(opt)
          h.merge!(validator_class.new(opt_value).to_h(:org3))
        elsif Org3Dumper::OPTION_MAP.has_key?(opt)
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

    def dump_schema_for_object_schema(schema, params = {})
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

    def dump_schema_for_array_schema(schema, params = {})
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

    def dump_schema_for_composite_schema(schema, params = {})
      dump_schema(schema.schema, params)
    end

    def dump_command_name(schema, *args)
      dispatch("dump_command_name", schema.class, schema, *args)
    end

    def dump_command_name_for_schema(schema)
      schema.class.command_name
    end

    def dump_command_name_for_numeric_schema(schema)
      "number"
    end

    def dump_command_name_for_integer_schema(schema)
      "integer"
    end

    def dump_command_name_for_string_schema(schema)
      "string"
    end

    def dump_options(schema, *args)
      dispatch("dump_options", schema.class, schema, *args)
    end

    def dump_options_for_schema(schema)
      {}
    end

    def dump_options_for_uri_schema(schema)
      { "format" => "uri" }
    end

    def dump_options_for_regexp_schema(schema)
      { "format" => "regex" }
    end

    def dump_options_for_datetime_schema(schema)
      { "format" => "date-time" }
    end

    def dump_options_for_ipv4_addr_schema(schema)
      { "format" => "ip-address" }
    end

    def dump_options_for_ipv6_addr_schema(schema)
      { "format" => "ipv6" }
    end

    private

    # Perform a virtual dispatch on a single object.
    # FIXME(Nicolas Despres): Get me out of here and test me.
    def dispatch(prefix, klass, object, *args, &block)
      symbol = "#{prefix}_for_#{klass.name.demodulize.underscore}"
      if respond_to? symbol
        send(symbol, object, *args, &block)
      else
        if klass == BasicObject
          raise NoMethodError, "undefined method '#{symbol}' for schema class #{object.class}"
        else
          dispatch(prefix, klass.superclass, object, *args, &block)
        end
      end
    end

  end

end
