require 'active_support/dependencies/autoload'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/integer/inflections'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/string/strip'

# Setup inflection rules for our acronyms
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym "URI"
  inflect.acronym "UTC"
  inflect.acronym "IP"
  inflect.acronym "JSON"
end

# Provide methods and classes to define, validate, sanitize and dump object schema.
#
# Classes in this module are split in 5 groups:
# * The _schema_ classes are the core of this module since they support the validation
#   process and are the internal representation of schema specification (see {Schema}).
# * The _definition_ classes (aka _def_ classes) are the front-end of this module since
#   they implement the schema definition DSL (see {GlobalDef}).
# * The _validator_ classes implement validation routine you can attach to your schema.
#   accessible via the schema's options (see {Validator}).
# * The _dumper_ classes are the back-end of this module since they implement the
#   convertion of the internal schema representation to different formats.
# * The _miscellaneous_ classes provides various support for the other categories.
#
# You can extend this library in many ways:
#
# 1. If you want to add your own schema class, you can sub-class the {CompositeSchema}
#    class. Sub-classing of the {Schema} class is not well supported yet as it may have
#    some issues with the current dumpers (see {DslDumper} and {Org3Dumper}). Fortunately,
#    most of the cases can be handled by {CompositeSchema}.
# 1. If you want to simply add new statements to the schema definition DSL, you can just
#    bundle them in a module and call {Respect.extend_dsl_with} (see {CoreStatements} for
#    further information).
#
# Extension of the _validator_ and _dumper_ classes is still experimental. Also, creating
# custom _definition_ classes is not recommended yet.
module Respect
  extend ActiveSupport::Autoload

  # Schema classes
  autoload :Schema
  autoload :HashSchema
  autoload :IntegerSchema
  autoload :FloatSchema
  autoload :NumericSchema
  autoload :StringSchema
  autoload :ArraySchema
  autoload :AnySchema
  autoload :BooleanSchema
  autoload :NullSchema
  autoload :URISchema
  autoload :RegexpSchema
  autoload :DatetimeSchema
  autoload :IPAddrSchema
  autoload :Ipv4AddrSchema
  autoload :Ipv6AddrSchema
  autoload :UTCTimeSchema
  autoload :HasConstraints
  autoload :CompositeSchema
  # Validator classes
  autoload :Validator
  autoload :EqualToValidator
  autoload :GreaterThanValidator
  autoload :GreaterThanOrEqualToValidator
  autoload :LessThanValidator
  autoload :LessThanOrEqualToValidator
  autoload :DivisibleByValidator
  autoload :MultipleOfValidator
  autoload :InValidator
  autoload :MatchValidator
  autoload :MinLengthValidator
  autoload :MaxLengthValidator
  autoload :FormatValidator
  # DSL classes
  autoload :SchemaDef
  autoload :ArrayDef
  autoload :HashDef
  autoload :GlobalDef
  autoload :ItemsDef
  autoload :CoreStatements
  autoload :DefWithoutName
  autoload :FakeNameProxy
  # Dumper classes
  autoload :DslDumper
  autoload :Org3Dumper
  # Miscellaneous classes
  autoload :DocParser
  autoload :JSONSchemaHTMLFormatter

  # Base error of all errors raised by this module.
  class RespectError < StandardError
  end

  # Raised when the validation process has failed.
  class ValidationError < RespectError
    def initialize(message)
      super
      @context = [ message ]
    end

    # An array of error messages to help you track where
    # the error happened. Use it as a back-trace but in
    # your validated object instead of your code.
    attr_reader :context
  end

  # Raised when you did an illegal operation while defining
  # a schema. See it as an ArgumentError but more specific.
  class InvalidSchemaError < RespectError
  end

  class << self

    # Extend the schema definition DSL with the statements defined in the given
    # module +mod+. Its methods would be available to each definition class
    # calling {GlobalDef.include_core_statements}.
    def extend_dsl_with(mod)
      raise ArugmentError, "cannot extend DSL with CoreStatements" if mod == CoreStatements
      CoreStatements.send(:include, mod)
      # We must "refresh" all the classes include "CoreStatements" by re-including it to
      # work around the
      # {dynamic module include problem}[http://eigenclass.org/hiki/The+double+inclusion+problem]
      GlobalDef.core_contexts.each{|c| c.send(:include, CoreStatements) }
    end

    STATEMENT_NAME_REGEXP = /^[a-z_][a-z_0-9]*$/

    # Build a schema class name from the given +statement_name+.
    def schema_name_for(statement_name)
      unless statement_name =~ STATEMENT_NAME_REGEXP
        raise ArgumentError, "statement '#{statement_name}' name must match #{STATEMENT_NAME_REGEXP.inspect}"
      end
      const_name = statement_name.to_s
      if const_name == "schema"
        "#{self.name}::Schema"
      else
        "#{self.name}::#{const_name.camelize}Schema"
      end
    end

    # Return the schema class associated to the given +statement_name+.
    #
    # A "valid" schema class must verify the following properties:
    # * Named like +StatementNameSchema+ in {Respect} module.
    # * Be a sub-class of {Schema}.
    # * Be concrete (i.e. have a public method +new+)
    def schema_for(statement_name)
      klass = Respect.schema_name_for(statement_name).safe_constantize
      if klass && klass < Schema && klass.public_methods.include?(:new)
        klass
      else
        nil
      end
    end

    # Test whether a schema is defined for the given +statement_name+.
    def schema_defined_for?(statement_name)
      !!schema_for(statement_name)
    end

    # Turn the given string (assuming it is a constraint name) into a
    # validator class name string.
    def validator_name_for(constraint_name)
      "#{self.name}::#{constraint_name.to_s.camelize}Validator"
    end

    # Turn the given +constraint_name+ into a validator class symbol.
    # Return nil if the validator class does not exist.
    def validator_for(constraint_name)
      validator_name_for(constraint_name).safe_constantize
    end

    # Test whether a validator is defined for the given +constraint_name+.
    def validator_defined_for?(constraint_name)
      !!validator_for(constraint_name)
    end

    # Sanitize the given +object+ *in-place* according to the given +sanitized_object+.
    # A sanitized object contains value with more specific data type. Like a URI
    # object instead of a plain string.
    #
    # Non-sanitized value are not touch (i.e. values present in +object+ but not in
    # +sanitized_object+). However, +object["key"]+ and +object[:key]+ are considered as
    # referring to the same value, but they original key would be preserved.
    #
    # Example:
    #   object = { "int" => "42" }
    #   Respect.sanitize_object!(object, { "int" => 42 }
    #   object                                     #=> { "int" => 42 }
    #   object = { :int => "42" }
    #   Respect.sanitize_object!(object, { "int" => 42 }
    #   object                                     #=> { :int => 42 }
    #
    # The sanitized object is accessible via the {Schema#sanitized_object} method after a
    # successful validation.
    def sanitize_object!(object, sanitized_object)
      case object
      when Hash
        if sanitized_object.is_a? Hash
          sanitized_object.each do |name, value|
            if object.has_key?(name)
              object[name] = sanitize_object!(object[name], value)
            else
              object[name.to_sym] = sanitize_object!(object[name.to_sym], value)
            end
          end
          object
        else
          sanitized_object
        end
      when Array
        if sanitized_object.is_a? Array
          sanitized_object.each_with_index do |value, index|
            object[index] = sanitize_object!(object[index], value)
          end
          object
        else
          sanitized_object
        end
      else
        sanitized_object
      end
    end

  end

end
