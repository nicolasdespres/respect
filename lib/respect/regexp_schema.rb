module Respect
  class RegexpSchema < StringSchema

    def validate_format(doc)
      FormatValidator.new.validate_regexp(doc)
    end

  end # class RegexpSchema
end # module Respect
