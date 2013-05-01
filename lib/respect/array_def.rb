module Respect
  class ArrayDef < BaseDef
    include DefWithoutName

    def initialize(options = {})
      @array_schema = ArraySchema.new(options)
    end

    def items(&block)
      @array_schema.items = ItemsDef.eval(&block)
    end

    def extra_items(&block)
      @array_schema.extra_items = ItemsDef.eval(&block)
    end

    private

    def evaluation_result
      @array_schema
    end

    def update_context(name, schema)
      @array_schema.item = schema
    end
  end
end
