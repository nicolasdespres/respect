module Respect
  class CompositeSchema < Schema

    class << self

      def composed_by(&block)
        public_class_method :new
        define_method(:composed_by) do
          Schema.define(&block)
        end
      end

      def sanitize(&block)
        define_method(:sanitize) do |doc|
          block.call(doc)
        end
      end

    end

    def initialize(options = {})
      super
      @schema = composed_by
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

    def composed_by
      raise NoMethodError, "implement me in sub-class or use the 'composed_by' macro"
    end

    def sanitize(doc)
      doc
    end

  end # class CompositeSchema
end # module Respect
