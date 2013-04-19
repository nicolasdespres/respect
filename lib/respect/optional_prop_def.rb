module Respect
  class OptionalPropDef < BaseDef
    def initialize
      @properties = {}
    end

    private

    def evaluation_result
      @properties
    end

    def update_result(name, schema)
      @properties[name] = schema
    end

  end
end
