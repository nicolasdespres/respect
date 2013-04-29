module Respect
  class UriSchema < StringSchema

    def validate_format(doc)
      FormatValidator.new(:uri).validate(doc)
    end

  end # class UriSchema
end # module Respect
