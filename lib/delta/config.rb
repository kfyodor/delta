module Delta
  class Config
    attr_reader :adapters

    class Adapters
      class UndefinedAdapterException < Exception
        def initialize(adapter)
          super "Undefined adapter `#{adapter}`"
        end
      end

      def initialize(adapters)
        @adapters = []
        adapters.each { |a| self.<<(a) }
      end

      def each(&block)
        @adapters.each &block
      end

      def <<(adapter)
        begin
          require "delta/adapters/active_record"
          @adapters << adapter
        rescue LoadError
          raise UndefinedAdapterException.new(adapter)
        end
      end
    end

    def initialize
      self.adapters = ["active_record"]
    end

    def adapters=(adapter_names)
      @adapters = Adapters.new(adapter_names)
    end
  end
end
