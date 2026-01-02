# Rixby

Rixby uses Ruby 4.0's new `Ruby::Box` namespacing system to add explicit `import`/`export` syntax to Ruby, similar to ES Modules.

Export the items you want to make public, and import only the items you need.
This makes the source of methods or classes explicit.

Unlike `require`, it also prevents files from "leaking" into each other.
(That is, if `b` imports `a` and `c` imports `b`, `c` does not see `b`'s imports from `a`.)

<table>
<tr>
  <td>shapes.rb</td><td>main.rb</td>
</tr>
<tr>
  <td>

```ruby
class Rectangle export
  # ...
end

class Circle export
  # ...
end

export def unit_square = Rectangle.new(1, 1)
```

  </td>
  <td>

```ruby
import { from 'shapes', :Circle, :unit_square }

p Circle.new(...)
p unit_square
# `Rectangle` is not available here
```

  </td>

</tr>

</table>

> [!TIP]
> For a more complete example, see the `example` directory.
> Start from `canvas.rb`.


> [!CAUTION]
> This is a proof-of-concept/experiment.
> **Do not use this in production!**


## Usage

Rixby requires Ruby 4.0+.

1. Install the gem: `gem install rixby` or `bundle add rixby`
2. Enable the experimental box feature: `export RUBY_BOX=1`
3. Run Ruby with `-rixby` to make `import` and `export` available everywhere:
  * (This is an `ubygems`-style alias - it's really `-r ixby`)

```
ruby -rixby main.rb
```

Export classes or modules by calling `export` within their body:

```ruby
class X
  export
  # ...
end

# or, more concisely, this also works
class X export
  # ...
end
```

Export methods by prepending `export` to their definition:

```ruby
export def something
  # ...
end
```

To import classes, modules, or methods, use one of these two forms of `import`:

```ruby
#                     symbol names of each item to import ...........
import { from 'file', :something_to_import, :something_else_to_import }

# Or, import everything
import { all 'file' }
```

## How does it work?

`Ruby::Box` is Ruby 4.0's new namespacing feature.
You can execute code in a box, and it acts as an isolated namespace for that code.

Rixby works by executing each imported file in a box.
Rixby injects `export` into the top-level namespace of the box, and tracks calls to it using an instance variable on the box.
Later, `import` reads from that instance variables to extract classes/modules/methods and copy them into the current box.

The `import` syntax needs some explaining - it uses a block even though there's no obvious need to:

```ruby
# This is what Rixby uses:
import { from 'file', :A, :B }

# Couldn't this just be...?
import 'file', :A, :B
```

This is a sly trick to give `import` a `Binding` for the parent scope.

Blocks come along with a `Binding` for the callee scope.
By accessing this, Rixby to define the imported methods or constants within that parent scope.

The alternative would be to require `binding` to be passed explicitly to each `import` call, but that would be much uglier.

## Why is it called that?

**R**u**by** **I**mport E**x**port... look, it's not the name that matters ;)
