require_relative 'import_dsl'

# Store boxes for imported files as an instance variable on the main box.
# Unlike a constant, this means all boxes are accessing the same value.
if Ruby::Box.current == Ruby::Box.main
  Ruby::Box.main.instance_variable_set(:@__rixby_boxes, {})
end

def import(&blk)
  unless block_given?
    raise 'you must pass a block to `import` describing the items to import'
  end

  import_desc = ImportDsl.evaluate(&blk)
  filename = import_desc.filename

  # TODO: file paths should be relative to importer. currently relative to CWD
  absolute_filename = File.expand_path(filename)
  imported_boxes = Ruby::Box.main.instance_variable_get(:@__rixby_boxes)
  if imported_boxes.has_key?(absolute_filename)
    box = imported_boxes[absolute_filename]
  else
    box = Ruby::Box.new
    box.instance_variable_set(:@__rixby_imported, true)
    box.require(__FILE__)
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

  # TODO: This works for methods and classes, probably not for constants etc
  block_binding = blk.binding
  imports.each do |import|
    export = exports[import] or raise(KeyError, "no export named `#{import}`")

    case export
    when Method
      block_binding.receiver.define_singleton_method(import, &export)
    when Class
      block_binding.receiver.class.const_set(import, export)
    else
      raise "internal error: unsupported export type #{export}"
    end
  end
end

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
    value = singleton_method(item)
  when Class
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
EXPORT_METHOD = method(:export)

Module.define_method(:export) do
  EXPORT_METHOD.(self)
end
