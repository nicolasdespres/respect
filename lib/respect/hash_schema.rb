module Respect
  # A schema to specify the structure of a hash.
  #
  # This schema defines the structure of a hash by listing
  # the expected property name and they associated schema.
  #
  # Property can be define by using a symbol, a string or a regular
  # expression.  In the later case, the associated schema will be used
  # to validate the value of all the properties matching the regular
  # expression. You can get the list of all pattern properties
  # using the {#pattern_properties} method.
  #
  # You can specify optional property by either setting the "required"
  # option to false or y setting a non nil default value.
  # You can get the list of all optional properties using the
  # {#optional_properties} method.
  #
  # Access to the document's value being validated is done using either
  # string key or symbol key. In other word +{ i: "42" }+ and
  # +{ "i" => "42" }+ are the same document for the {#validate} method.
  # The document object passed is left untouched. The sanitized document
  # is a hash with indifferent access. Note that when a document
  # is sanitized in-place, its original keys are kept
  # (see {Respect.sanitize_object!}). Only validated keys are included
  # in the sanitized document.
  #
  # You can pass several options when creating an {HashSchema}:
  # strict:: if set to +true+ the hash must not have any extra
  #          properties to be validated. (+false+ by default)
  class HashSchema < Schema

    undef_default_statement

    class << self
      # Overwritten method. See Schema::default_options
      def default_options
        super().merge({
            strict: false,
          }).freeze
      end
    end

    public_class_method :new

    def initialize(options = {})
      super(self.class.default_options.merge(options))
      @properties = {}
    end

    def initialize_copy(other)
      super
      @properties = other.properties.dup
    end

    # Get the schema for the given property +name+.
    def [](name)
      @properties[name]
    end

    # Set the given +schema+ for the given property +name+. A name can be
    # a Symbol, a String or a Regexp.
    def []=(name, schema)
      case name
      when Symbol, String, Regexp
        if @properties.has_key?(name)
          raise InvalidSchemaError, "property '#{name}' already defined"
        end
        @properties[name] = schema
      else
        raise InvalidSchemaError, "unsupported property name type #{name}:#{name.class}"
      end
    end

    # Returns the set of properties of this schema index by their name.
    attr_reader :properties

    # Overwritten method. See {Schema#validate}.
    def validate(doc)
      # Validate document format.
      unless doc.is_a?(Hash)
        raise ValidationError, "document is not a hash but a #{doc.class}"
      end
      unless doc.is_a?(HashWithIndifferentAccess)
        doc = doc.with_indifferent_access
      end
      sanitized_object = {}.with_indifferent_access
      # Validate expected properties.
      @properties.each do |name, schema|
        case name
        when Symbol
          validate_property_with_options(name.to_s, schema, doc, sanitized_object)
        when String
          validate_property_with_options(name, schema, doc, sanitized_object)
        when Regexp
          doc.select{|prop, schema| prop =~ name }.each do |prop, value|
            validate_property(prop, schema, doc, sanitized_object)
          end
        end
      end
      if options[:strict]
        # Check whether there are extra properties.
        doc.each do |name, schema|
          unless sanitized_object.has_key? name
            raise ValidationError, "unexpected key `#{name}'"
          end
        end
      end
      self.sanitized_object = sanitized_object
      true
    end

    def validate_property_with_options(name, schema, doc, sanitized_object)
      if doc.has_key? name
        validate_property(name, schema, doc, sanitized_object)
      else
        if schema.required?
          raise ValidationError, "missing key `#{name}'"
        else
          if schema.has_default?
            sanitized_object[name] = schema.default
          end
        end
      end
    end
    private :validate_property_with_options

    def validate_property(name, schema, doc, sanitized_object)
      begin
        schema.validate(doc[name])
        sanitized_object[name] = schema.sanitized_object
      rescue ValidationError => e
        e.context << "in hash property `#{name}'"
        raise e
      end
    end
    private :validate_property

    # Return the optional properties (e.g. those that are not required).
    def optional_properties
      @properties.select{|name, schema| schema.optional? }
    end

    # Return all the properties identified by a regular expression.
    def pattern_properties
      @properties.select{|name, schema| name.is_a?(Regexp) }
    end

    # In-place version of {#merge}. This schema is returned.
    def merge!(hash_schema)
      @options.merge!(hash_schema.options)
      @properties.merge!(hash_schema.properties)
      self
    end

    # Merge the given +hash_schema+ with this object schema. It works like
    # +Hash.merge+.
    def merge(hash_schema)
      self.dup.merge!(hash_schema)
    end

    # Return whether +property_name+ is defined in this hash schema.
    def has_property?(property_name)
      @properties.has_key?(property_name)
    end

    # Evaluate the given block as a hash schema definition (i.e. in the context of
    # {Respect::HashDef}) and merge the result with this hash schema.
    # This is a way to "re-open" this hash schema definition to add some more.
    def eval(&block)
      self.merge!(HashSchema.define(&block))
    end

    # Return all the properties with a non-false documentation.
    def documented_properties
      @properties.select{|name, schema| schema.documented? }
    end

    def ==(other)
      super && @properties == other.properties
    end

  end
end
