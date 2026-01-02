export def assert_equal(expected, actual)
  if expected != actual
    raise "assertion failed: #{expected} != #{actual}"
  end  
end
