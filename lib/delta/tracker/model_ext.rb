module Delta
  class Tracker
    module ModelExt
      def self.included(base)
        base.send :include, Cache
        base.send :include, DeltaAssociationHelpers
      end

      module Cache
        def cache_deltas(deltas)
          @deltas_cache ||= []
          @deltas_cache += deltas
        end

        def deltas_cache
          @deltas_cache || []
        end

        def reset_deltas_cache!
          @deltas_cache = []
        end
      end
    end

    module DeltaAssociationHelpers
      def delta_association_add(assoc_name, obj)
        delta_association_invoke_action(assoc_name, obj, "A")
      end

      def delta_association_remove(assoc_name, obj)
        delta_association_invoke_action(assoc_name, obj, "R")
      end

      def delta_association_change(assoc_name, obj)
        delta_association_invoke_action(assoc_name, obj, "C")
      end

      private

      def delta_association_invoke_action(assoc_name, obj, action)
        key = obj.class.primary_key

        self.class.delta_tracker.send :persist_or_cache!, self, {
          name: assoc_name,
          action: action,
          timestamp: Time.now.to_i,
          object: { key => obj.send(key) }
        }
      end
    end
  end
end
