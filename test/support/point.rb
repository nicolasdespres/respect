class Point
  def initialize(x, y)
    @x, @y = x, y
  end

  attr_reader :x, :y

  def ==(other)
    @x == other.x && @y == other.y
  end
end
