require_relative 'import_dsl'

def import(&blk)
  unless block_given?
    raise 'you must pass a block to `import` describing the items to import'
  end

  import_desc = ImportDsl.evaluate(&blk)
  filename = import_desc.filename

  # TODO: Need to keep boxes coherent between imports somehow. Very unfinished
  # (i.e. so you don't end up re-defining classes)
  # Need some global caching like `require` does
  box = Ruby::Box.new
  box.require(__FILE__)
  box.require(filename)

  exports = box.instance_variable_get(:@__rixby_exports)
  case import_desc.imports
  when :all
    imports = exports.keys
  when Array
    imports = import_desc.imports
  else
    raise 'internal error: malformed import array'
  end

  # TODO: This works for methods, probably not for constants etc
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
