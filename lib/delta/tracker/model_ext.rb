module Delta
  class Tracker
    module ModelExt
      def self.included(base)
        base.send :include, Cache
        base.send :include, HasManyMethods
        base.send :include, HasOneMethods
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

    module HasManyMethods
      def delta_after_add(assoc_name, primary_key, obj)
        self.class.delta_tracker.send :persist_or_cache!, self, {
          name: assoc_name,
          action: "A",
          timestamp: Time.now.to_i,
          object: { primary_key => obj.send(primary_key) }
        }
      end

      def delta_after_remove(assoc_name, primary_key, obj)
        self.class.delta_tracker.send :persist_or_cache!, self, {
          name: assoc_name,
          action: "R",
          timestamp: Time.now.to_i,
          object: { primary_key => obj.send(primary_key) }
        }
      end
    end

    module HasOneMethods
    end
  end
end
