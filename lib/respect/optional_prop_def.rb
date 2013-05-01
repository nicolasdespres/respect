module Respect
  class OptionalPropDef < BaseDef
    def initialize
      @properties = {}
    end

    private

    def evaluation_result
      @properties
    end

    def update_context(name, schema)
      @properties[name] = schema
    end

  end
end
