module Respect
  class DatetimeSchema < StringSchema

    def validate_type(object)
      FormatValidator.new(:datetime).validate(object)
    end

  end # class DatetimeSchema
end # module Respect
