module Respect
  # A composite schema is a schema composed of another schema.
  #
  # Sub-classing {CompositeSchema} is the easiest way to add a user-defined
  # schema. Indeed, you just have to overwrite {#schema_definition} and optionally
  # {#sanitize}. Your schema will be handled properly by all other part
  # of the library (i.e. mainly dumpers and the DSL).
  #
  # Example:
  #   module Respect
  #     class PointSchema < CompositeSchema
  #       def schema_defintion
  #         HashSchema.define do |s|
  #           s.numeric "x"
  #           s.numeric "y"
  #         end
  #       end
  #
  #       def sanitize(object)
  #         # Assuming you have defined a Point class.
  #         Point.new(object[:x], object[:y])
  #       end
  #     end
  #   end
  #
  # A "point" method will be available in the DSL so you could use
  # your schema like that:
  #
  # Example:
  #   HashSchema.define do |s|
  #     s.point "origin"
  #   end
  class CompositeSchema < Schema

    class << self
      def inherited(subclass)
        subclass.public_class_method :new
      end
    end

    def initialize(options = {})
      super
      @schema = self.schema_definition
    end

    # Returns the schema composing this schema.
    attr_reader :schema

    # Overloaded methods (see {Schema#validate}).
    def validate(object)
      @schema.validate(object)
      self.sanitized_object = sanitize(@schema.sanitized_object)
      true
    end

    # Returns the schema composing this composite schema.
    # Overwrite this methods in sub-class.
    def schema_definition
      raise NoMethodError, "implement me in sub-class"
    end

    # Sanitize the given validated +object+. Overwrite this method
    # in sub-class and returns the object that would be inserted
    # in the sanitized object. The object passed as argument
    # is an already sanitized sub-part of the overall object
    # being validated. By default this method is a no-op. It
    # returns the given +object+.
    def sanitize(object)
      object
    end

  end # class CompositeSchema
end # module Respect
