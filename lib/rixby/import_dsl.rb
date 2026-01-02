module Rixby
  module ImportDsl
    # Evaluation target for the `import` block
    class ImportDslReceiver
      def initialize
        @filename = nil
        @imports = []
      end

      attr_reader :filename, :imports

      def from(filename, *imports)
        @filename = filename
        @imports = imports

        if @imports.empty?
          raise ArgumentError, 'import list cannot be empty. if you want to import everything, use `all` instead'
        end

        @imports.each do |import|
          unless import.is_a?(Symbol)
            raise TypeError, "imported names must be symbols, but got: #{import}"
          end
        end
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
end
