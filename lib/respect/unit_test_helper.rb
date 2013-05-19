module Respect
  module UnitTestHelper
    def assert_schema_validation_is(expected, schema, object, msg = nil)
      valid = schema.validate?(object)
      if expected
        if !valid
          if msg
            message = msg
          else
            message = "Schema:\n#{schema}expected to validate object <#{object.inspect}> but failed with \"#{schema.last_error.context.join(" ")}\"."
          end
          assert false, message
        end
      else
        if valid
          if msg
            message = msg
          else
            message = "Schema:\n#{schema}expected to invalidate object <#{object.inspect}> but succeed."
          end
          assert false, message
        end
      end
    end

    def assert_schema_validate(schema, object, msg = nil)
      assert_schema_validation_is(true, schema, object, msg)
    end

    def assert_schema_invalidate(schema, object, msg = nil)
      assert_schema_validation_is(false, schema, object, msg)
    end

  end # module UnitTestHelper
end # module Respect

Test::Unit::TestCase.send :include, Respect::UnitTestHelper
