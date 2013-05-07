module Respect
  # Test class proving that users can easily extend the schema hierarchy
  # with a custom type providing both a composition macro and a
  # sanitizer block.
  class PointSchema < CompositeSchema

    def schema_definition
      HashSchema.define do |s|
        s.float "x"
        s.float "y"
      end
    end

    def sanitize(doc)
      Point.new(doc["x"], doc["y"])
    end

  end
end
