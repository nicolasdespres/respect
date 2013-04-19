module Respect
  class UriSchema < StringSchema

    def validate_format(doc)
      FormatValidator.new.validate_uri(doc)
    end

  end # class UriSchema
end # module Respect
