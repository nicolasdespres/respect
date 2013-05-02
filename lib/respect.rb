require 'active_support/dependencies/autoload'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/integer/inflections'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/string/strip'

# Provide methods and classes to define, validate, sanitize and dump JSON schema.
#
# Classes in this module are split in 5 groups:
# * The _schema_ classes are the core of this module since they support the validation
#   process and are the internal representation of schema specification.
# * The _definition_ classes (aka _def_ classes) are the front-end of this module since
#   they implement the schema definition DSL.
# * The _validator_ classes are support classes implementing the different validators
#   accessible via the schema's options.
# * The _dumper_ classes are the back-end of this module since the implement the convertion
#   of the internal schema representation to different formats.
# * The _miscellaneous_ classes provides various support for the other categories.
#
# You can extend this library in many ways:
#
# 1. If you want to add your own schema class, you can sub-class the {CompositeSchema}
#    class. Sub-classing of the {Schema} class is not well supported yet as it may have
#    some issues with the current dumpers (see {DslDumper} and {Org3Dumper}). Fortunately,
#    most of the cases can be handled by {CompositeSchema}.
# 1. If you want to simply add some commands to the schema definition DSL, you can just
#    bundle them in a module and call {Respect.extend_dsl_with} (see {BasicCommands} for
#    further information).
#
# Extension of the _validator_ and _dumper_ classes is still experimental. Also, creating
# custom _definition_ classes is not recommended.
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
  autoload :FakeNameProxy
  # Dumper classes
  autoload :DslDumper
  autoload :Org3Dumper
  # Miscellaneous classes
  autoload :DocParser

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
    # your JSON document instead of your code.
    attr_reader :context
  end

  # Raised when you did an illegal operation while defining
  # a schema. See it as an ArgumentError but more specific.
  class InvalidSchemaError < RespectError
  end

  class << self

    # Extend the schema definition DSL with the command defined in the given
    # module +mod+.
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

    # Build a schema class name from the given +command_name+.
    def schema_name_for(command_name)
      const_name = command_name.to_s
      if const_name == "schema"
        "#{self.name}::Schema"
      else
        "#{self.name}::#{const_name.camelize}Schema"
      end
    end

    # Return the schema class associated to the given +command_name+.
    #
    # A "valid" schema class must verify the following properties:
    # * Named like +CommnandNameSchema+ in {Respect} module.
    # * Be a sub-class of {Schema}.
    # * Be concrete (i.e. have a public method +new+)
    def schema_for(command_name)
      klass = Respect.schema_name_for(command_name).safe_constantize
      if klass && klass < Schema && klass.public_methods.include?(:new)
        klass
      else
        nil
      end
    end

    # Test whether a schema is defined for the given +command_name+.
    def schema_defined_for?(command_name)
      !!schema_for(command_name)
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

  end

  extend_dsl_with(BasicCommands)

end
