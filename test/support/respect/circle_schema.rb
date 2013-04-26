module Respect
  # Test class proving that users can easily extend the schema hierarchy
  # with a custom type based on another custom type.
  class CircleSchema < CompositeSchema
    def schema
      ObjectSchema.define do |s|
        s.point "center"
        s.float "radius", greater_than: 0.0
      end
    end

    def sanitize(doc)
      Circle.new(doc[:center], doc[:radius])
    end
  end
end
