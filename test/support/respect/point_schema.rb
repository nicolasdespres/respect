module Respect
  # Test class proving that users can easily extend the schema hierarchy
  # with a custom type providing both a composition macro and a
  # sanitizer block.
  class PointSchema < CompositeSchema

    composed_by do |s|
      s.object do |s|
        s.float "x"
        s.float "y"
      end
    end

    sanitize do |doc|
      Point.new(doc["x"], doc["y"])
    end

  end
end
