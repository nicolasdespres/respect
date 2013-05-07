module Respect
  # Dump a schema to a string representation using the DSL syntax so you
  # can evaluate it and get the same schema back.
  #
  # Theoretically, this must always be true:
  #   eval(DslDumper.new(schema).dump) == schema
  #
  # The current implementation covers all the _Schema_ and _Validator_
  # classes defined in this package. User-defined sub-class of {Schema}
  # are not guarantee to work. Specially those using a custom "Def" class
  # or with special attributes. The API of this dumper is *experimental*,
  # so relying on it to teach the dumper how to dump a user-defined schema
  # class may break in future releases.
  #
  # However, sub-classes of {CompositeSchema} are handled
  # properly as well as all {Validator} sub-classes.
  class DslDumper

    def initialize(schema)
      @schema = schema
      @indent_level = 0
      @indent_size = 2
      @context_data = {}
    end

    attr_reader :schema, :output

    def dump(output = nil)
      @output = output
      @output ||= String.new
      self << "Respect::Schema.define do |s|"
      self.indent do
        self.dump_schema(@schema)
      end
      self << "\nend\n"
      @output
    end

    def <<(str)
      @output << str.gsub(/(\n+)/, "\\1#{indentation}")
      self
    end

    def indent(count = 1, &block)
      @indent_level += count
      if block
        block.call
        unindent(count)
      end
    end

    def unindent(count = 1)
      @indent_level -= count
    end

    def indentation
      " " * @indent_size * @indent_level
    end

    attr_accessor :context_data

    def dump_block(args = [ "s" ], &block)
      self << " do |#{args.join(', ')}|"
      self.indent(&block)
      self << "\nend"
    end

    def dump_schema(schema)
      self.dump_doc(schema)
      self << "\ns."
      self.dump_name(schema)
      self.dump_arguments(schema)
      self.dump_body(schema)
      self
    end

    def dump_doc(schema, prefix = false)
      if schema.doc
        if schema.description
          self << "\n"
          self << %q{s.doc <<-EOS.strip_heredoc}
          self.indent do
            self << "\n"
            self << schema.doc
            self << "EOS"
          end
        else
          self << "\ns.doc \"#{schema.title}\""
        end
      end
    end

    def dump_name(schema)
      self << schema.class.statement_name
    end

    def dump_arguments(schema)
      # Fetch name if there is one?
      if self.context_data.has_key?(:name)
        name = self.context_data[:name]
      else
        name = nil
      end
      # Compute options to dump.
      options = schema.non_default_options.reject do |opt|
        opt == :doc
      end
      # Dump name and options
      if name || !options.empty?
        if name
          self << " "
          self << name.inspect
        end
        if !options.empty?
          if name
            self << ","
          end
          self << " "
          self.dump_options(schema)
        end
      end
      self
    end

    def dump_options(schema)
      options = schema.non_default_options
      option_keys = options.keys
      option_keys.each do |opt|
        self << opt.inspect
        self << " => "
        self << options[opt].inspect
        self << ", " unless opt == option_keys.last
      end
      self
    end

    def dump_body(schema)
      symbol = "dump_body_for_#{schema.class.statement_name}"
      if respond_to? symbol
        send(symbol, schema)
      end
    end

    def dump_body_for_hash(schema)
      dump_block do
        schema.properties.each do |name, schema|
          context_data[:name] = name
          dump_schema(schema)
        end
      end
    end

    def dump_body_for_array(schema)
      dump_block do
        context_data.delete(:name)
        if schema.item
          dump_schema(schema.item)
        end
        if schema.items && !schema.items.empty?
          self << "\ns.items do |s|"
          indent do
            schema.items.each do |schema|
              dump_schema(schema)
            end
          end
          self << "\nend"
        end
        if schema.extra_items && !schema.extra_items.empty?
          self << "\ns.extra_items do |s|"
          indent do
            schema.extra_items.each do |schema|
              dump_schema(schema)
            end
          end
          self << "\nend"
        end
      end
    end
  end

end # module Respect
