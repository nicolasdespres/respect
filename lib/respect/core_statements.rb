module Respect
  # Core DSL statements definition module.
  #
  # This module holds all the basic statements available in the DSL. It is included
  # in all the DSL context using {Respect.extend_dsl_with}. Thus all basic DSL
  # contexts provides its feature.
  #
  # Most of the statements are available as dynamic methods.
  # For each "FooSchema" class defined in the {Respect} module (and following certain
  # condition described at {Respect.schema_for}), there is a statement
  # "foo" (see {Schema.statement_name}) expecting a name, some options and a block.
  # This statement defines a new "FooSchema" with the given options and block. This
  # schema is stored in the current context using the given name. The name may be used
  # differently depending on the context. In a hash definition context it will be
  # used as a property name whereas it will be simply ignored in the
  # context of an array. Context classes including the {DefWithoutName} module ignore
  # the name argument whereas others do not. The {FakeNameProxy} is in charge of
  # transparently passing +nil+ for the name in contexts including the {DefWithoutName}
  # module.
  #
  # Example:
  #   HashSchema.define do |s|
  #     # method_missing calls:
  #     #   update_context("i", IntegerSchema.define({greater_than: 42}))
  #     s.integer "i", greater_than: 42
  #   end
  #   ArraySchema.define do |s|
  #     # method_missing calls:
  #     #   update_context(nil, IntegerSchema.define({greater_than: 42}))
  #     s.integer greater_than: 42
  #   end
  #
  # Classes including this module must implement the +update_context+ method
  # which is supposed to update the schema under definition with the given
  # name and schema created by the method.
  #
  # Do not include your helper module in this module since definition classes
  # including it won't be affected due to the
  # {dynamic module include problem}[http://eigenclass.org/hiki/The+double+inclusion+problem].
  # To extend the DSL use {Respect.extend_dsl_with} instead.
  #
  # It is recommended that your macros implementation be based on core statements
  # because +update_context+ API is *experimental*. If you do so anyway your
  # macros may not work properly with the {#doc} and {#with_options} statements.
  module CoreStatements

    # @!method string(name, options = {})
    #   Define a {StringSchema} with the given +options+ and stores it in the
    #   current context using +name+ as index.
    # @!method integer(name, options = {})
    #   Define a {IntegerSchema} with the given +options+ and stores it in the
    #   current context using +name+ as index.
    # @!method float(name, options = {})
    #   Define a {FloatSchema} with the given +options+ and stores it in the
    #   current context using +name+ as index.
    # @!method numeric(name, options = {})
    #   Define a {NumericSchema} with the given +options+ and stores it in the
    #   current context using +name+ as index.
    # @!method any(name, options = {})
    #   Define a {AnySchema} with the given +options+ and stores it in the
    #   current context using +name+ as index.
    # @!method null(name, options = {})
    #   Define a {NullSchema} with the given +options+ and stores it in the
    #   current context using +name+ as index.
    # @!method boolean(name, options = {})
    #   Define a {BooleanSchema} with the given +options+ and stores it in the
    #   current context using +name+ as index.
    # @!method uri(name, options = {})
    #   Define a {URISchema} with the given +options+ and stores it in the
    #   current context using +name+ as index.
    # @!method hash(name, options = {}, &block)
    #   Define a {HashSchema} with the given +options+ and +block+ stores it
    #   in the current context using +name+ as index.
    # @!method array(name, options = {})
    #   Define a {ArraySchema} with the given +options+ and +block+ stores it
    #   in the current context using +name+ as index.
    # @!method datetime(name, options = {})
    #   Define a {DatetimeSchema} with the given +options+ and stores it in the
    #   current context using +name+ as index.
    # @!method ip_addr(name, options = {})
    #   Define a {IPAddrSchema} with the given +options+ and stores it in the
    #   current context using +name+ as index.
    # @!method ipv4_addr(name, options = {})
    #   Define a {Ipv4AddrSchema} with the given +options+ and stores it in the
    #   current context using +name+ as index.
    # @!method ipv6_addr(name, options = {})
    #   Define a {Ipv6AddrSchema} with the given +options+ and stores it in the
    #   current context using +name+ as index.
    # @!method regexp(name, options = {})
    #   Define a {RegexpSchema} with the given +options+ and stores it in the
    #   current context using +name+ as index.
    # @!method utc_time(name, options = {})
    #   Define a {UTCTimeSchema} with the given +options+ and stores it in the
    #   current context using +name+ as index.
    #
    # Call +update_context+ using the first argument as index and passes the rest
    # to the {Schema.define} class method of the schema class associated with the method name.
    # As a consequence any call to missing method +foo+ will define a +FooSchema+
    # schema using +FooSchema.define+.
    #
    # The options are merged with the default options which may include the +:doc+
    # option if {#doc} has been called before. The current documentation is reset
    # after this call.
    #
    # Note that if you define a new schema named after a method already defined in
    # a context class such as {GlobalDef} or its sub-classes or in +Object+, the
    # dynamic dispatch won't work. For instance even if you have defined the
    # +ClassSchema+ class the following code won't work as expected:
    #
    #   Schema.define do |s|
    #     s.class  # Call Object#class !!!!!
    #   end
    #
    # To prevent this problem you must undefine the method in the DSL by doing
    # something like that:
    #
    #   module Respect
    #     class GlobalDef
    #       undef_method :class
    #     end
    #   end
    #
    # or you can override the +class+ method in the context of your choice:
    #
    #   module Respect
    #     class GlobalDef
    #       def class(name, options = {}, &block)
    #         update_context name, ClassSchema.define(options, &block)
    #       end
    #     end
    #   end
    #
    # Do not un-define or override 'method' and 'methods' since {FakeNameProxy}
    # use them.
    def method_missing(method_name, *args, &block)
      if respond_to_missing?(method_name, false)
        size_range = 1..2
        if size_range.include? args.size
          name = args.shift
          default_options = {}
          default_options.merge!(@options) unless @options.nil?
          default_options[:doc] = @doc unless @doc.nil?
          if options = args.shift
            options = default_options.merge(options)
          else
            options = default_options
          end
          @doc = nil
          update_context name, Respect.schema_for(method_name).define(options, &block)
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

    # @!method email(name, options = {})
    #   Define a string formatted an email (see {FormatValidator#validate_email}).
    # @!method phone_number(name, options = {})
    #   Define a string formatted as a phone number (see {FormatValidator#validate_phone_number}).
    # @!method hostname(name, options = {})
    #   Define a string formatted as a machine host name (see {FormatValidator#validate_hostname}).
    [
      :email,
      :phone_number,
      :hostname,
    ].each do |meth_name|
      define_method(meth_name) do |name, options = {}|
        string name, options.dup.merge(format: meth_name)
      end
    end

    # Define the current documentation text. It will be used as documentation for the
    # next defined schema. It can be used once, so it is reset once it has been affected
    # to a schema.
    #
    # Example:
    #   s = HashSchema.define do |s|
    #     s.doc "A magic number"
    #     s.integer "magic"
    #     s.integer "nodoc"
    #     s.doc "A parameter..."
    #     s.string "param"
    #   end
    #   s["magic"].doc                  #=> "A magic number"
    #   s["nodoc"].doc                  #=> nil
    #   s["param"].doc                  #=> "A parameter..."
    def doc(text)
      @doc = text
    end

    # Use +options+ as the default for all schema created within +block+.
    def with_options(options, &block)
      @options = options
      FakeNameProxy.new(self).eval(&block)
      @options = nil
    end

  end # module CoreStatements
end # module Respect
