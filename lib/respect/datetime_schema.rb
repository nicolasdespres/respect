module Respect
  class DatetimeSchema < StringSchema

    def validate_format(doc)
      FormatValidator.new(:datetime).validate(doc)
    end

  end # class DatetimeSchema
end # module Respect
