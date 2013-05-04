module Respect
  module UnitTestHelper
    def assert_schema_validation_is(expected, schema, doc, msg = nil)
      valid = schema.validate?(doc)
      if expected
        if !valid
          if msg
            message = msg
          else
            message = "Schema:\n#{schema}expected to validate doc <#{doc}> but failed with '#{schema.last_error.context.join(" ")}'."
          end
          assert false, message
        end
      else
        if valid
          if msg
            message = msg
          else
            message = "Schema:\n#{schema}expected to invalidate doc <#{doc}> but succeed."
          end
          assert false, message
        end
      end
    end

    def assert_schema_validate(schema, doc, msg = nil)
      assert_schema_validation_is(true, schema, doc, msg)
    end

    def assert_schema_invalidate(schema, doc, msg = nil)
      assert_schema_validation_is(false, schema, doc, msg)
    end

  end # module UnitTestHelper
end # module Respect

Test::Unit::TestCase.send :include, Respect::UnitTestHelper
