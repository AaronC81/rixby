import { from 'canvas', :Canvas }
import { from 'shapes', :Rectangle, :Circle }
import { from 'assertion', :assert_equal }

export def canvas_demo
  canvas = Canvas.new
  canvas.add_circle(2)
  canvas.add_rectangle(4, 5)

  assert_equal 2, canvas.shapes.length
  assert_equal Circle.new(2), canvas.shapes[0]
  assert_equal Rectangle.new(4, 5), canvas.shapes[1]

  puts canvas.total_area
end

canvas_demo
