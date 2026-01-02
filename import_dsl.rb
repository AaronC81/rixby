module ImportDsl
  # Evaluation target for the `import` block
  class ImportDslReceiver
    def initialize
      @filename = nil
      @imports = []
    end

    attr_reader :filename, :imports

    def from(**kw)
      raise ArgumentError unless kw.length == 1
      @filename, @imports = kw.to_a.first
    end
    
    def all(filename)
      @filename = filename
      @imports = :all
    end
  end

  def self.evaluate(&blk)
    recv = ImportDslReceiver.new
    recv.instance_exec(&blk)

    if recv.filename.nil?
      raise RuntimeError, 'import block did not specify anything to import'
    end

    recv
  end
end
