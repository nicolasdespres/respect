module Respect
  # Basic DSL command definition module.
  #
  # This module holds all the commands available in the DSL. It is included
  # in all the DSL context classes using Respect::extend_dsl_with.
  # Classes including this module must implement the 'update_result' method
  # which is supposed to update the schema under definition with the given
  # name and schema.
  module BasicCommands

    def method_missing(method_name, *args, &block)
      if respond_to_missing?(method_name, false)
        size_range = 1..2
        if size_range.include? args.size
          name = args.shift
          default_options = {}
          default_options[:doc] = @doc unless @doc.nil?
          if options = args.shift
            options = default_options.merge(options)
          else
            options = default_options
          end
          @doc = nil
          update_result name, Respect.schema_for(method_name).define(options, &block)
        else
          expected_size = args.size > size_range.end ? size_range.end : size_range.begin
          raise ArgumentError, "wrong number of argument (#{args.size} for #{expected_size})"
        end
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_all)
      Respect.schema_defined_for?(method_name)
    end

    [
      :email,
      :phone_number,
      :hostname,
    ].each do |meth_name|
      define_method(meth_name) do |name, options = {}, &block|
        string name, options.dup.merge(format: meth_name), &block
      end
    end

    def doc(text)
      @doc = text
    end

  end # module BasicCommands
end # module Respect
