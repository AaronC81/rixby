require_relative 'rixby/import_dsl'

# Store boxes for imported files as an instance variable on the main box.
# Unlike a constant, this means all boxes are accessing the same value.
if Ruby::Box.current == Ruby::Box.main
  Ruby::Box.main.instance_variable_set(:@__rixby_boxes, {})
end

# Import items from a file.
#
# Requires a block in one of the following two forms:
#
#   1. Import particular items from the file (which must be `export`-ed):
#      ```
#      import { from 'file', :a, :b, :c }
#      ```
#
#   2. Import everything which was `export`-ed from the file:
#      ```
#      import { all: 'file' }
#      ```
#
# Imports are only visible to the current file.
# Files which import this file will not see the same imports.
#
def import(&blk)
  unless block_given?
    raise 'you must pass a block to `import` describing the items to import'
  end

  # The syntax uses a block specifically so that we can pinch the binding, and define new things in it
  block_binding = blk.binding

  import_desc = Rixby::ImportDsl.evaluate(&blk)
  filename = import_desc.filename

  relative_to = File.dirname(block_binding.source_location[0])
  absolute_filename = File.expand_path(filename, relative_to)

  # Add `.rb` automatically if that would create a valid path
  if !File.exist?(absolute_filename) && File.exist?(absolute_filename + '.rb')
    absolute_filename += '.rb'
  end

  # Only import each file into a box once.
  # Otherwise we'll end up with a new definition of each class every time we import something, and
  # they won't compare equally.
  imported_boxes = Ruby::Box.main.instance_variable_get(:@__rixby_boxes)
  if imported_boxes.has_key?(absolute_filename)
    box = imported_boxes[absolute_filename]
  else
    box = Ruby::Box.new
    box.instance_variable_set(:@__rixby_imported, true)
    box.require(__FILE__) # Enable `import`/`export` in that file too
    box.require(absolute_filename)
    imported_boxes[absolute_filename] = box
  end

  exports = box.instance_variable_get(:@__rixby_exports)
  case import_desc.imports
  when :all
    imports = exports.keys
  when Array
    imports = import_desc.imports
  else
    raise 'internal error: malformed import array'
  end

  # Copy imports into the current scope.
  imports.each do |import|
    export = exports[import] or raise(KeyError, "no export named `#{import}`")

    case export
    when Method
      block_binding.receiver.define_singleton_method(import, &export)
    when Module
      block_binding.receiver.class.const_set(import, export)
    else
      raise "internal error: unsupported export type #{export}"
    end
  end
end

# Export an item from this file, so it's visible to `import`.
#
# Call either on a method definition, or from within a class/module:
#
# ```
# export def something
#   # ...
# end
#
# class Foobar export
#   # ...
# end
# ```
#
def export(item)
  # If this file isn't being imported, we can ignore `export`.
  # This is relevant if you `export` from the main file, where `singleton_method` doesn't seem to be
  # able to look up methods correctly.
  unless Ruby::Box.current.instance_variable_get(:@__rixby_imported)
    return
  end

  case item
  when Symbol
    key = item
    # Try both - sometimes one works, sometimes the other, I'm not sure why.
    value = method(item) rescue singleton_method(item)
  when Module
    key = item.name.split('::').last.to_sym
    value = item
  else
    raise ArgumentError, "unsupported item for export: #{item}"
  end

  box = Ruby::Box.current
  unless box.instance_variable_defined?(:@__rixby_exports)
    box.instance_variable_set(:@__rixby_exports, {})
  end

  exports = box.instance_variable_get(:@__rixby_exports)
  exports[key] = value
end

# Enables `export` to be called from within a class or module to export that item
EXPORT_METHOD = method(:export)
Module.define_method(:export) do
  EXPORT_METHOD.(self)
end
