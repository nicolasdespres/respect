module Respect
  class DatetimeSchema < StringSchema

    def validate_type(doc)
      FormatValidator.new(:datetime).validate(doc)
    end

  end # class DatetimeSchema
end # module Respect
