module Respect
  class RegexpSchema < StringSchema

    def validate_type(object)
      FormatValidator.new(:regexp).validate(object)
    end

  end # class RegexpSchema
end # module Respect
