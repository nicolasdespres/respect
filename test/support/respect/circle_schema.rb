module Respect
  # Test class proving that users can easily extend the schema hierarchy
  # with a custom type based on another custom type.
  class CircleSchema < CompositeSchema
    composed_by do |s|
      s.object do |s|
        s.point "center"
        s.float "radius", greater_than: 0.0
      end
    end

    sanitize do |doc|
      Circle.new(doc[:center], doc[:radius])
    end
  end
end
