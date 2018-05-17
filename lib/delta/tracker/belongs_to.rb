module Delta
  class Tracker
    class BelongsTo < Association
      def track!
      end

      def serialize(model, action, opts = {})
        return unless model.changes[key] || (polymorphic? && model.changes[type])

        assoc      = model.send(@name)
        key        = @reflection.klass.primary_key
        serialized = if assoc
                       { key => assoc.send(key) }.tap do |hash|
                         @opts[:type] = assoc.class.name if polymorphic?
                         @opts[:serialize].each { |col| hash[col] = assoc.send col }
                       end
                     else
                       { key => nil }
                     end

        {
          name:      @name,
          action:    action,
          timestamp: opts[:timestamp] || Time.now.to_i,
          object:    serialized
        }
      end

      private

      def polymorphic?
        type.present?
      end

      def key
        @reflection.foreign_key
      end

      def type
        @reflection.foreign_type
      end
    end
  end
end
