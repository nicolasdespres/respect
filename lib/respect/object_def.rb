module Respect
  class ObjectDef < BaseDef

    def initialize(options = {})
      @object_schema = ObjectSchema.new(options)
    end

    def optionals(&block)
      with_options(required: false, &block)
    end

    private

    def evaluation_result
      @object_schema
    end

    def update_context(name, schema)
      @object_schema[name] = schema
    end
  end
end
