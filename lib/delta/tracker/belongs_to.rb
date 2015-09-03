module Delta
  class Tracker
    class BelongsTo < Association
      def track!
      end

      def serialize(model, action, opts = {})
        key = @reflection.foreign_key
        return unless model.changes[key]

        assoc      = model.association_cache[@name] || model.send(@name)
        key        = assoc.class.primary_key
        serialized = { key => assoc.send(key) }.tap do |hash|
          @opts[:serialize].each { |col| hash[col] = assoc.send col }
        end

        {
          name:      @name,
          action:    action,
          timestamp: opts[:timestamp] || Time.now.to_i,
          object:    serialized
        }
      end
    end
  end
end
