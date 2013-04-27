module Respect
  class ObjectDef < BaseDef

    def initialize(options = {})
      @object_schema = ObjectSchema.new(options)
    end

    def optionals(&block)
      OptionalPropDef.eval(&block).each do |name, schema|
        schema.options[:required] = false
        update_result(name, schema)
      end
    end

    private

    def evaluation_result
      @object_schema
    end

    def update_result(name, schema)
      @object_schema[name] = schema
    end
  end
end
