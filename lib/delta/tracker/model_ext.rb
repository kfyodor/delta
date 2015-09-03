module Delta
  class Tracker
    module ModelExt
      def self.included(base)
        base.send :include, Cache
        base.send :include, DeltaFieldsMethods
        base.send :include, DeltaAssociationsMethods
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
        delta_tracker.belongs_to_associations.each do |name, reflection|
          key = reflection.foreign_key

          next unless changed_assoc = changes[key]

          deltas << {
            name: name,
            action: "C",
            timestamp: timestamp,
            object: { reflection.association_primary_key => changed_assoc.last }
          }
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
        key = obj.class.primary_key

        self.class.delta_tracker.send :persist!, self, {
          name: assoc_name,
          action: action,
          timestamp: Time.now.to_i,
          object: { key => obj.send(key) }
        }
      end
    end
  end
end
