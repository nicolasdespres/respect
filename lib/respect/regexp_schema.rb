module Respect
  class RegexpSchema < StringSchema

    def validate_format(doc)
      FormatValidator.new(:regexp).validate(doc)
    end

  end # class RegexpSchema
end # module Respect
