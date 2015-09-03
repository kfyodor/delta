module Delta
  class Tracker
    class Attribute < TrackableField
      def initialize(name, attr, opts = {})
        @name, @attr, @opts = name, attr, opts
      end

      def track!; end

      def serialize(model, action, opts = {})
        return unless changed = model.changes[@name]

        {
          name: @name,
          action: "C",
          timestamp: opts[:timestamp] || Time.now.to_i,
          object: changed.last
        }
      end
    end
  end
end
