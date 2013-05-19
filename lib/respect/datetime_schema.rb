module Respect
  # Validate a date and time string following RFC 3399.
  #
  # If validation succeed the sanitized object is a +DateTime+ object.
  class DatetimeSchema < StringSchema

    def validate_type(object)
      case object
      when NilClass
        if allow_nil?
          nil
        else
          raise ValidationError, "object is nil but this #{self.class} does not allow nil"
        end
      when DateTime
        object
      when Time
        object.to_datetime
      when Date
        object.to_date
      else
        FormatValidator.new(:datetime).validate(object)
      end
    end

  end # class DatetimeSchema
end # module Respect
