module Respect
  class ItemsDef < GlobalDef
    include_core_statements
    include DefWithoutName

    def initialize
      @items = []
    end

    private

    def evaluation_result
      @items
    end

    def update_context(name, schema)
      @items << schema
      schema
    end
  end
end
