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
        @schema.dump_as_dsl(self)
      end
      self << "\nend\n"
      @output
    end

    def <<(str)
      @output << str.gsub(/\n/, "\n#{indentation}")
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

  end # class DslDumper

  class Schema
    def dump_as_dsl(dumper)
      dumper << "\ns."
      dump_command_name_as_dsl(dumper)
      dump_command_arguments_as_dsl(dumper)
      dump_command_block_as_dsl(dumper)
      dumper
    end

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
      options = self.non_default_options
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
      dump_command_metadata_as_dsl(dumper)
    end

    def dump_command_metadata_as_dsl(dumper, prefix = false)
      if self.metadata
        title = self.metadata.title
        desc = self.metadata.description
        if title || desc
          if prefix
            dumper << "\ns.metadata"
          end
          dumper.dump_block(["m"]) do
            dumper << "\nm.title " << title.inspect if title
            dumper << "\nm.description { " << desc.inspect << " }" if desc
          end
        end
      end
    end
  end

  class ObjectSchema < Schema
    def dump_command_block_as_dsl(dumper)
      dumper.dump_block do
        dump_command_metadata_as_dsl(dumper, true)
        @properties.each do |name, schema|
          dumper.context_data[:name] = name
          schema.dump_as_dsl(dumper)
        end
      end
    end
  end

  class ArraySchema < Schema
    def dump_command_block_as_dsl(dumper)
      dumper.dump_block do
        dumper.context_data.delete(:name)
        dump_command_metadata_as_dsl(dumper, true)
        if @item
          @item.dump_as_dsl(dumper)
        end
        if @items && !@items.empty?
          dumper << "\ns.items do |s|"
          dumper.indent do
            @items.each do |schema|
              schema.dump_as_dsl(dumper)
            end
          end
          dumper << "\nend"
        end
        if @extra_items && !@extra_items.empty?
          dumper << "\ns.extra_items do |s|"
          dumper.indent do
            @extra_items.each do |schema|
              schema.dump_as_dsl(dumper)
            end
          end
          dumper << "\nend"
        end
      end
    end
  end

end # module Respect
