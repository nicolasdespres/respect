module Respect
  module MetadataCommand

    def metadata(&block)
      @metadata = MetadataDef.eval(&block)
    end

    private

    def update_metadata(schema)
      schema.metadata = @metadata if schema && @metadata
    end

  end # module MetadataCommand
end # module Respect
