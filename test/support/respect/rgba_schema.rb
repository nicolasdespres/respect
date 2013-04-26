module Respect
  # Test class proving that users can easily extend the schema hierarchy
  # with a composite schema based on an array schema.
  class RgbaSchema < CompositeSchema
    def schema
      ArraySchema.define do |s|
        s.items do |s|
          s.color_channel # red
          s.color_channel # green
          s.color_channel # blue
          s.color_channel # alpha
        end
      end
    end

    def sanitize(doc)
      Rgba.new(doc[0], doc[1], doc[2], doc[3])
    end
  end
end
