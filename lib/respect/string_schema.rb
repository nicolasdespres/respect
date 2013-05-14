module Respect
  class StringSchema < Schema
    include HasConstraints

    public_class_method :new

    def validate_type(object)
      object.to_s
    end

  end
end
