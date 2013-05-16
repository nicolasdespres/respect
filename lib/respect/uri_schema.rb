module Respect
  class URISchema < StringSchema

    def validate_type(object)
      FormatValidator.new(:uri).validate(object)
    end

  end # class URISchema
end # module Respect
