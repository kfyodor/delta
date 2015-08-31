require 'set'
require 'thread'

module Delta
  class Config
    attr_reader :adapters

    ## TODO: user model name
    ##       user foreign key???

    class Adapters
      class UndefinedAdapterException < Exception
        def initialize(adapter)
          super "Undefined adapter `#{adapter}`"
        end
      end

      def initialize(adapters)
        @adapters = Set.new
        @lock     = Mutex.new
        adapters.each { |a| self.<<(a) }
      end

      def each(&block)
        @adapters.each &block
      end

      def <<(adapter)
        begin
          require File.expand_path("../adapters/#{adapter}", __FILE__)
          kl = Delta::Adapter.build_klass(adapter)

          @lock.synchronize do
            if @adapters.add?(kl)
              Delta::Tracking.add_adapter_callback do |model|
                kl.register(model)
              end
            end
          end
        rescue LoadError, NameError => e
          puts e.message
          raise UndefinedAdapterException.new(adapter)
        end
      end
    end

    def initialize
      @adapters = Adapters.new(["active_record"])
    end

    def adapters=(adapter_names)
      @adapters = Adapters.new(adapter_names)
    end
  end
end
