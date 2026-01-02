def import(**kw, &blk)
  raise unless kw.length == 1

  # The block is never executed, only used to get a binding for the caller.
  # TODO: see if we can use the block as part of a DSL
  unless block_given?
    raise 'you must pass an empty block to `import` for implementation reasons'
  end

  filename, imports = kw.to_a.first

  # TODO: Need to keep boxes coherent between imports somehow. Very unfinished
  # (i.e. so you don't end up re-defining classes)
  # Need some global caching like `require` does
  box = Ruby::Box.new
  box.require(filename)

  exports = box.instance_variable_get(:@__rixby_exports)

  # TODO: This works for methods, probably not for constants etc
  block_binding = blk.binding
  imports.each do |import|
    export = exports[import] or raise(KeyError, "no export named `#{import}`")
    block_binding.receiver.define_singleton_method(import, &export)
  end
end

def export(item)
  case item
  when Symbol
    key = item
    value = singleton_method(item)
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
