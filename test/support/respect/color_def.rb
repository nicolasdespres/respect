module Respect
  class ColorDef < GlobalDef
    def initialize(options = {})
      @color_schema = ColorSchema.new(options)
    end

    [ :red, :green, :blue, :alpha ].each do |name|
      define_method(name) do |value|
        @color_schema.send("#{name}=", value)
      end
    end

    private

    def evaluation_result
      @color_schema
    end
  end
end
