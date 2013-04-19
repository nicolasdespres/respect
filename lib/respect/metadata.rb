module Respect
  class Metadata

    class << self
      def define(&block)
        MetadataDef.eval(&block)
      end
    end

    attr_accessor :title, :description

    def to_h
      h = {}
      h['title'] = @title if @title
      h['description'] = @description if @description
      h
    end
  end # class Metadata
end # module Respect
