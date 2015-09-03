module Delta
  class Tracker
    module ModelExt
      def self.included(base)
        base.send :include, Cache
        base.send :include, DeltaFieldsMethods
        base.send :include, DeltaAssociationsMethods

        base.class_eval do
          after_update { persist_delta_fields! }
          after_commit { reset_deltas_cache! }
        end
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

    module DeltaFieldsMethods
      def persist_delta_fields!
        return if changes.empty?

        ts = Time.now.to_i
        deltas = []

        collect_delta_belongs_to_associations(deltas, ts)
        collect_delta_attributes(deltas, ts)

        unless deltas.empty?
          delta_tracker.persist!(self, deltas)
        end
      end

      private

      def collect_delta_belongs_to_associations(deltas, timestamp)
        delta_tracker.belongs_to_associations.each do |name, assoc|
          if serialized = assoc.serialize(self, "C", timestamp: timestamp)
            deltas << serialized
          end
        end
      end

      def collect_delta_attributes(deltas, timestamp)
        delta_tracker.attributes.each do |col, _|
          next unless changed_column = changes[col]

          deltas << {
            name: col,
            action: "C",
            timestamp: timestamp,
            object: changed_column.last
          }
        end
      end
    end

    module DeltaAssociationsMethods
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
        serialized = delta_tracker
          .trackable_fields[assoc_name]
          .serialize(obj, action)

        delta_tracker.persist! self, serialized
      end
    end
  end
end
