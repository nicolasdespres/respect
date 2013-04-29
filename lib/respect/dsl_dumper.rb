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
      schema.dump_command_name_as_dsl(self)
      schema.dump_command_arguments_as_dsl(self)
      schema.dump_command_block_as_dsl(self)
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
  end

  class Schema
    def dump_command_name_as_dsl(dumper)
      dumper << self.class.command_name
    end

    def dump_command_arguments_as_dsl(dumper)
      # Fetch name if there is one?
      if dumper.context_data.has_key?(:name)
        name = dumper.context_data[:name]
      else
        name = nil
      end
      # Compute options to dump.
      options = self.non_default_options.reject do |opt|
        opt == :doc
      end
      # Dump name and options
      if name || !options.empty?
        if name
          dumper << " "
          dumper << name.inspect
        end
        if !options.empty?
          if name
            dumper << ","
          end
          dumper << " "
          dump_command_options_as_dsl(dumper)
        end
      end
      dumper
    end

    def dump_command_options_as_dsl(dumper)
      options = self.non_default_options
      option_keys = options.keys
      option_keys.each do |opt|
        dumper << opt.inspect
        dumper << " => "
        dumper << options[opt].inspect
        dumper << ", " unless opt == option_keys.last
      end
      dumper
    end

    def dump_command_block_as_dsl(dumper)
    end

  end

  class ObjectSchema < Schema
    def dump_command_block_as_dsl(dumper)
      dumper.dump_block do
        @properties.each do |name, schema|
          dumper.context_data[:name] = name
          dumper.dump_schema(schema)
        end
      end
    end
  end

  class ArraySchema < Schema
    def dump_command_block_as_dsl(dumper)
      dumper.dump_block do
        dumper.context_data.delete(:name)
        if @item
          dumper.dump_schema(@item)
        end
        if @items && !@items.empty?
          dumper << "\ns.items do |s|"
          dumper.indent do
            @items.each do |schema|
              dumper.dump_schema(schema)
            end
          end
          dumper << "\nend"
        end
        if @extra_items && !@extra_items.empty?
          dumper << "\ns.extra_items do |s|"
          dumper.indent do
            @extra_items.each do |schema|
              dumper.dump_schema(schema)
            end
          end
          dumper << "\nend"
        end
      end
    end
  end

end # module Respect
