require_relative './lib'

export def foo
  1
end

export def bar
  2
end

# Deliberately not exported
def baz
  3
end
