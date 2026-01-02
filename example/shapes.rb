class Rectangle export
  def initialize(width, height)
    @width = width
    @height = height
  end

  attr_reader :width, :height
  def area = width * height

  def ==(other) = other.is_a?(Rectangle) && width == other.width && height == other.height
  def hash = [width, height].hash
end

class Circle export
  def initialize(radius)
    @radius = radius
  end

  attr_reader :radius
  def area = radius * radius * Math::PI

  def ==(other) = other.is_a?(Circle) && radius == other.radius
  def hash = [radius].hash
end
