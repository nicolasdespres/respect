module Respect
  class HashDef < GlobalDef
    include_core_statements

    def initialize(options = {})
      @hash_schema = HashSchema.new(options)
    end

    def extra(&block)
      with_options(required: false, &block)
    end

    private

    def evaluation_result
      @hash_schema
    end

    def update_context(name, schema)
      @hash_schema[name] = schema
    end
  end
end
