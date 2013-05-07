module Respect
  class SchemaDef < GlobalDef
    include_core_statements
    include DefWithoutName

    private

    def evaluation_result
      @schema
    end

    def update_context(name, schema)
      @schema = schema
    end
  end
end
