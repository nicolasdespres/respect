module Respect
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
      self.dump_schema_doc(schema)
      self << "\ns."
      self.dump_command_name(schema)
      self.dump_command_arguments(schema)
      self.dump_command_block(schema)
      self
    end

    def dump_schema_doc(schema, prefix = false)
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

    def dump_command_name(schema)
      self << schema.class.command_name
    end

    def dump_command_arguments(schema)
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
          self.dump_command_options(schema)
        end
      end
      self
    end

    def dump_command_options(schema)
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

    def dump_command_block(schema)
      case schema
      when ObjectSchema
        dump_command_block_for_object(schema)
      when ArraySchema
        dump_command_block_for_array(schema)
      end
    end

    def dump_command_block_for_object(schema)
      dump_block do
        schema.properties.each do |name, schema|
          context_data[:name] = name
          dump_schema(schema)
        end
      end
    end

    def dump_command_block_for_array(schema)
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
