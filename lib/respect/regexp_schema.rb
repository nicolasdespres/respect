module Respect
  class RegexpSchema < StringSchema

    def validate_type(doc)
      FormatValidator.new(:regexp).validate(doc)
    end

  end # class RegexpSchema
end # module Respect
