module Respect
  # A composite schema is a schema composed of another schema.
  #
  # Sub-classing {CompositeSchema} is the easiest way to add a user-defined
  # schema. Indeed, you just have to overwrite {#schema} and optionally
  # {#sanitize}. Your schema will be handled properly by all other part
  # of the library (i.e. mainly dumpers and the DSL).
  #
  # Example:
  #   module Respect
  #     class PointSchema < CompositeSchema
  #       def schema
  #         ObjectSchema.define do |s|
  #           s.numeric "x"
  #           s.numeric "y"
  #         end
  #       end
  #
  #       def sanitize(doc)
  #         # Assuming you have defined a Point class.
  #         Point.new(doc[:x], doc[:y])
  #       end
  #     end
  #   end
  #
  # A "point" method will be available in the DSL so you could use
  # your schema like that:
  #
  # Example:
  #   ObjectSchema.define do |s|
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
      @schema = self.schema
    end

    def validate(doc)
      @schema.validate(doc)
      self.sanitized_doc = sanitize(@schema.sanitized_doc)
      true
    end

    # Returns the schema composing this composite schema.
    # Overwrite this methods in sub-class.
    def schema
      raise NoMethodError, "implement me in sub-class"
    end

    # Sanitize the given validated +doc+. Overwrite this method
    # in sub-class and returns the object that would be inserted
    # in the sanitized document. The document passed as argument
    # is an already sanitized sub-part of the overall document
    # being validated. By default this method is a no-op. It
    # returns the given +doc+.
    def sanitize(doc)
      doc
    end

  end # class CompositeSchema
end # module Respect
