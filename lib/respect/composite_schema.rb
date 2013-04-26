module Respect
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

    def schema
      raise NoMethodError, "implement me in sub-class"
    end

    def sanitize(doc)
      doc
    end

  end # class CompositeSchema
end # module Respect
