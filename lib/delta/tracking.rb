require 'thread'
require 'set'

module Delta
  module Tracking
    @@models            = Set.new
    @@adapter_callbacks = []
    @@lock              = Mutex.new

    class << self
      def included(base)
        base.class_attribute :delta_tracker
        base.extend ClassMethods
      end

      def model_added(model)
        @@lock.synchronize do
          @@adapter_callbacks.each do |proc|
            proc.call model
          end if @@models.add?(model)
        end
      end

      def add_adapter_callback(&block)
        @@adapter_callbacks << block
      end

      def models
        @@models
      end

      def add_model(model)
        @@lock.synchronize { @@models << model }
      end
    end

    module ClassMethods
      def track_deltas(*fields, **opts)
        init_delta_tracker(opts)
        delta_tracker.add_trackable_fields(fields)
      end

      def track_deltas_on(field, field_opts = {})
        init_delta_tracker({})
        delta_tracker.add_trackable_field(field, field_opts)
      end

      private

      def init_delta_tracker(opts)
        unless self.delta_tracker
          self.delta_tracker = Tracker.new(self, opts)
          Tracking.model_added(self)
          self.delta_tracker.track!
        end
      end
    end
  end
end
