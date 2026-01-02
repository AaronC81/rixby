import { from './shapes.rb', :Circle, :Rectangle }

class Canvas export
  def initialize
    @shapes = []
  end
  attr_reader :shapes

  def add_circle(radius)
    shapes << Circle.new(radius)
  end

  def add_rectangle(width, height)
    shapes << Rectangle.new(width, height)
  end

  def total_area = shapes.map(&:area).sum
end
