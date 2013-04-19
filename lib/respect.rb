require 'active_support/dependencies/autoload'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/integer/inflections'
require 'active_support/core_ext/hash/indifferent_access'

module Respect
  extend ActiveSupport::Autoload

  # Schema classes
  autoload :Schema
  autoload :ObjectSchema
  autoload :IntegerSchema
  autoload :FloatSchema
  autoload :NumericSchema
  autoload :StringSchema
  autoload :ArraySchema
  autoload :AnySchema
  autoload :BooleanSchema
  autoload :NullSchema
  autoload :UriSchema
  autoload :RegexpSchema
  autoload :DatetimeSchema
  autoload :IpAddrSchema
  autoload :Ipv4AddrSchema
  autoload :Ipv6AddrSchema
  autoload :UtcTimeSchema
  autoload :HasConstraints
  autoload :Metadata
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
  autoload :ObjectDef
  autoload :BaseDef
  autoload :OptionalPropDef
  autoload :ItemsDef
  autoload :BasicCommands
  autoload :DefWithoutName
  autoload :DefEvaluator
  autoload :MetadataDef
  autoload :MetadataCommand
  # Dumper classes
  autoload :DslDumper
  autoload :JsonSchemaV3HashDumper

  # Base error of all errors raised by this class.
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
    # your JSON document instead of your code.
    attr_reader :context
  end

  # Raised when you did an illegal operation while defining
  # a schema. See it as an ArgumentError but more specific.
  class InvalidSchemaError < RespectError
  end

  class << self

    # Extend the schema definition DSL with the command defined in the given
    # module _mod_.
    def extend_dsl_with(mod)
      [
        SchemaDef,
        ArrayDef,
        ItemsDef,
        ObjectDef,
        OptionalPropDef,
      ].each do |klass|
        klass.send(:include, mod)
      end
    end

    # Build a schema class name from the given _command_name_.
    def schema_name_for(command_name)
      const_name = command_name.to_s
      if const_name == "schema"
        "#{self.name}::Schema"
      else
        "#{self.name}::#{const_name.camelize}Schema"
      end
    end

    # Return the schema class associated to the given _command_name_.
    #
    # A "valid" schema class must verify the following properties:
    # - Named like CommnandNameSchema in Respect module.
    # - Be a sub-class of Respect::Schema.
    # - Be concrete (i.e. have a public method _new_)
    def schema_for(command_name)
      klass = Respect.schema_name_for(command_name).safe_constantize
      if klass && klass < Schema && klass.public_methods.include?(:new)
        klass
      else
        nil
      end
    end

    # Test whether a schema is defined for the given _command_name_.
    def schema_defined_for?(command_name)
      !!schema_for(command_name)
    end

    # Turn the given string (assuming it is a constraint name) into a
    # validator class name string.
    def validator_name_for(constraint_name)
      "#{self.name}::#{constraint_name.to_s.camelize}Validator"
    end

    # Turn the given _constraint_name_ into a validator class symbol.
    # Return nil if the validator class does not exist.
    def validator_for(constraint_name)
      validator_name_for(constraint_name).safe_constantize
    end

    # Test whether a validator is defined for the given _constraint_name_.
    def validator_defined_for?(constraint_name)
      !!validator_for(constraint_name)
    end

  end

  extend_dsl_with(BasicCommands)

end
