class Rgba
  def initialize(red, green, blue, alpha)
    @red, @green, @blue, @alpha = red, green, blue, alpha
  end

  attr_reader :red, :green, :blue, :alpha

  def ==(other)
    @red == other.red && @green == other.green && @blue == other.blue && @alpha == other.alpha
  end
end
