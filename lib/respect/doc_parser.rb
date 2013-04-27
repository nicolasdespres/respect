module Respect
  class DocParser

    def initialize
      @title = nil
      @description = nil
    end

    def parse(string)
      ss = StringScanner.new(string)
      if ss.scan_until(/\n/)
        if ss.eos?
          @title = ss.pre_match
        else
          if ss.scan(/\n+/)
            @title = ss.pre_match.chop
            unless ss.rest.empty?
              @description = ss.rest
            end
          else
            if ss.eos?
              @title = string.chop
            else
              @description = string
            end
          end
        end
      else
        @title = string
      end
      self
    end

    attr_reader :title, :description

  end # class DocParser
end # module Respect
