module Respect
  class StringSchema < Schema
    include HasConstraints

    public_class_method :new

    def validate_type(doc)
      doc.to_s
    end

  end
end
