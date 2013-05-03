module Respect
  class URISchema < StringSchema

    def validate_format(doc)
      FormatValidator.new(:uri).validate(doc)
    end

  end # class URISchema
end # module Respect
