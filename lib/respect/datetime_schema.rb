module Respect
  class DatetimeSchema < StringSchema

    def validate_format(doc)
      FormatValidator.new.validate_datetime(doc)
    end

  end # class DatetimeSchema
end # module Respect
