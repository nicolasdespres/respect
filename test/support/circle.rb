class Circle
  def initialize(center, radius)
    @center, @radius = center, radius
  end

  attr_reader :center, :radius

  def ==(other)
    @center == other.center && @radius == radius
  end
end
