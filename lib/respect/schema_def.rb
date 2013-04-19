module Respect
  class SchemaDef < BaseDef
    include DefWithoutName
    include MetadataCommand

    private

    def evaluation_result
      update_metadata @schema
      @schema
    end

    def update_result(name, schema)
      @schema = schema
    end
  end
end
