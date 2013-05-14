module Respect
  # A schema to specify a JSON object.
  #
  # This schema defines the structure of a JSON object by listing
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
  # You can pass several options when creating an {ObjectSchema}:
  # strict:: if set to +true+ the JSON object must not have any extra
  #          properties to be validated. (+false+ by default)
  class ObjectSchema < Schema

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
      sanitized_doc = {}.with_indifferent_access
      # Validate expected properties.
      @properties.each do |name, schema|
        case name
        when Symbol
          validate_property_with_options(name.to_s, schema, doc, sanitized_doc)
        when String
          validate_property_with_options(name, schema, doc, sanitized_doc)
        when Regexp
          doc.select{|prop, schema| prop =~ name }.each do |prop, value|
            validate_property(prop, schema, doc, sanitized_doc)
          end
        end
      end
      if options[:strict]
        # Check whether there are extra properties.
        doc.each do |name, schema|
          unless sanitized_doc.has_key? name
            raise ValidationError, "unexpected key `#{name}'"
          end
        end
      else
        # Copy extra properties verbatim.
        doc.each do |name, schema|
          unless sanitized_doc.has_key? name
            sanitized_doc[name] = schema
          end
        end
      end
      self.sanitized_doc = sanitized_doc
      true
    end

    def validate_property_with_options(name, schema, doc, sanitized_doc)
      if doc.has_key? name
        validate_property(name, schema, doc, sanitized_doc)
        sanitized_doc[name] = schema.sanitized_doc
      else
        if schema.required?
          raise ValidationError, "missing key `#{name}'"
        else
          if schema.has_default?
            sanitized_doc[name] = schema.default
          end
        end
      end
    end
    private :validate_property_with_options

    def validate_property(name, schema, doc, sanitized_doc)
      begin
        schema.validate(doc[name])
        sanitized_doc[name] = schema.sanitized_doc
      rescue ValidationError => e
        e.context << "in object property `#{name}'"
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
    def merge!(object_schema)
      @properties.merge!(object_schema.properties)
      self
    end

    # Merge the given +object_schema+ with this object schema. It works like
    # +Hash.merge+.
    def merge(object_schema)
      self.dup.merge!(object_schema)
    end

    # Return whether +property_name+ is defined in this object schema.
    def has_property?(property_name)
      @properties.has_key?(property_name)
    end

    # Evaluate the given block as an object schema definition (i.e. in the context of
    # {Respect::ObjectDef}) and merge the result with this object schema.
    # This is a way to "re-open" this object schema definition to add some more.
    def eval(&block)
      self.merge!(ObjectSchema.define(&block))
    end

    # Return all the properties with a non-false documentation.
    def documented_properties
      @properties.select{|name, schema| schema.documented? }
    end

  end
end
