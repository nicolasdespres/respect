module Respect
  # Validate a date and time string following RFC 3399.
  #
  # If validation succeed the sanitized object is a +DateTime+ object.
  class DatetimeSchema < StringSchema

    def validate_type(object)
      FormatValidator.new(:datetime).validate(object)
    end

  end # class DatetimeSchema
end # module Respect
