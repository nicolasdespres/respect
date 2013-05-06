module Respect
  class URISchema < StringSchema

    def validate_type(doc)
      FormatValidator.new(:uri).validate(doc)
    end

  end # class URISchema
end # module Respect
