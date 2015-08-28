module Delta
  module Changes
    def self.included(base)
      base.after_update :persist_changes!

      base.after_update  :reset_cache!
      base.after_create  :reset_cache!
      base.after_destroy :reset_cache!
    end

    def persist_changes!
      cache_columns_deltas!

      Delta.config.adapters.each do |adapter|
        Delta::Adapter
          .build_klass(adapter)
          .new(self, serialized_deltas_cache)
          .persist!
      end
    end

    def serialized_deltas_cache
      deltas_cache.serialize
    end

    def cache_association_delta!(change)
      deltas_cache.add_association change
    end

    def cache_column_delta!(change)
      deltas_cache.add_column change
    end

    private

    def reset_cache!
      @deltas_cache = Cache.new
    end

    class Cache
      attr_accessor :columns, :associations

      def initialize
        @columns      = []
        @associations = []
      end

      def add_association(assoc)
        @associations << assoc
      end

      def add_column(col)
        @columns << col
      end

      def serialize
        (associations + columns).sort do |c1, c2|
          c1[:timestamp] <=> c2[:timestamp]
        end
      end
    end

    def cache_columns_deltas!
      ts = Time.current.to_i

      clear_deltas_column_cache!

      self.class.delta_columns.keys.each do |col|
        next unless changed_column = changes[col]

        cache_column_delta!({
          name:      col,
          action:    "C",
          type:      "C",
          timestamp: ts,
          object:    changed_column.last
        })
      end
    end

    def clear_deltas_column_cache!
      deltas_cache.columns = []
    end

    def deltas_cache
      @deltas_cache ||= Cache.new
    end
  end
end
