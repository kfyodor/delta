module Delta
  class Tracker
    class Association
      def self.create(*args)
        self.new(*args).tap do |t|
          t.track!
        end
      end

      def initialize(trackable_class, name, reflection, opts = {})
        @trackable_class = trackable_class
        @name            = name
        @reflection      = reflection
        @opts            = opts
      end

      def track!
        raise NotImplemented
      end
    end
  end
end
