class Color
  class FormatError < StandardError
  end

  class << self
    def from_string(str)
      if str.to_s =~ /^#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/
        Color.new($1.to_i(16), $2.to_i(16), $3.to_i(16), $4.to_i(16))
      else
        raise FormatError, "'#{str}' does not match color regexp"
      end
    end
  end

  def initialize(red, green, blue, alpha)
    @red, @green, @blue, @alpha = red, green, blue, alpha
  end

  attr_reader :red, :green, :blue, :alpha

  def ==(other)
    @red == other.red && @green == other.green && @blue == other.blue && @alpha == other.alpha
  end
end
