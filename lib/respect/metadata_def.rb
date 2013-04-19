module Respect
  class MetadataDef < BaseDef

    def initialize()
      @metadata = Metadata.new
    end

    def title(title)
      @metadata.title = title
    end

    def description(&block)
      @metadata.description = block.call
    end

    private

    def evaluation_result
      @metadata
    end

  end # class MetadataDef
end # module Respect
