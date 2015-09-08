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
        if init_delta_tracker_if_needed(opts)
          delta_tracker.add_trackable_fields(fields)
        end
      end

      def track_deltas_on(field, field_opts = {})
        if init_delta_tracker_if_needed({})
          delta_tracker.add_trackable_field(field.to_s, field_opts)
        end
      end

      private

      def init_delta_tracker_if_needed(opts)
        unless connection.table_exists?(table_name)
          # TODO proper logging / errors
          Rails.logger.warn("[Delta] `#{table_name}` doesn't exist: skipping initialization.")
          return nil
        end

        delta_tracker || begin
          self.delta_tracker = Tracker.new(self, opts)
          Tracking.model_added(self)
          delta_tracker.track!
        end
      end
    end
  end
end
