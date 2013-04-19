module Respect
  class StringSchema < Schema
    include HasConstraints

    public_class_method :new

    def validate_format(doc)
      doc.to_s
    end

  end
end
