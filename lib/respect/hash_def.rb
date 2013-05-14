module Respect
  class HashDef < GlobalDef
    include_core_statements

    def initialize(options = {})
      @hash_schema = HashSchema.new(options)
    end

    def extra(&block)
      with_options(required: false, &block)
    end

    # Shortcut to say a schema +key+ must be equal to a given +value+. When it
    # does not recognize the value type it creates a "any" schema.
    #
    # Example:
    #   HashSchema.define do |s|
    #     s["a_string"] = "value"       # equivalent to: s.string("a_string", equal_to: "value")
    #     s["a_key"] = 0..5             # equivalent to: s.any("a_key", equal_to: "0..5")
    #   end
    def []=(key, value)
      case value
      when String
        string(key, equal_to: value.to_s)
      else
        any(key, equal_to: value.to_s)
      end
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
