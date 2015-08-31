require 'thread'
require 'set'

module Delta
  module Tracking

    @@models            = Set.new
    @@adapter_callbacks = []
    @@lock              = Mutex.new

    class << self
      def included(base)
        base.extend ClassMethods
      end

      def model_added(model)
        @@lock.synchronize do
          if @@models.add?(model)
            @@adapter_callbacks.each do |proc|
              proc.call model
            end
          end
        end
      end

      def add_adapter_callback(&block)
        @@adapter_callbacks << block
      end

      def models
        @@models
      end

      def add_model(model)
        @@lock.synchronize do
          @@models << model
        end
      end
    end

    module ClassMethods
      def track_deltas(*fields)
        class_attribute :delta_tracker
        self.delta_tracker = Delta::Tracker.new(self, fields, {})

        Tracking.model_added(self)
        delta_tracker.track!
      end
    end
  end
end
