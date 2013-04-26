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
      if @schema.sanitized_doc.is_a? Hash
        doc_to_resanitize = @schema.sanitized_doc.with_indifferent_access
      else
        doc_to_resanitize = @schema.sanitized_doc.dup
      end
      self.sanitized_doc = sanitize(doc_to_resanitize)
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
