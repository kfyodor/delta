module Delta
  class Tracker
    class TrackableField
      def self.create(*args)
        self.new(*args).tap do |t|
          t.track!
        end
      end

      def track!
        raise NotImplemented
      end

      def serialize(obj, action, opts = {})
        raise NotImplemented
      end
    end
  end
end
