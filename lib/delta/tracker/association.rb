module Delta
  class Tracker
    class Association
      class WrongOption < Exception; end

      def self.create(*args)
        self.new(*args).tap do |t|
          t.track!
        end
      end

      def initialize(trackable_class, name, reflection, opts = {})
        @trackable_class = trackable_class
        @name            = name
        @reflection      = reflection
        @opts            = build_opts(opts)
      end

      def track!
        raise NotImplemented
      end

      def serialize(obj, action)
        key        = obj.class.primary_key
        serialized = { key => obj.send(key) }

        @opts[:serialize].each do |f|
          serialized[f] = obj.send(f)
        end

        {
          name: @name,
          action: action,
          timestamp: Time.now.to_i,
          object: serialized
        }
      end

      private

      def build_opts(opts)
        {}.tap do |o|
          o[:serialize] = opts[:serialize] || []

          unless o[:serialize].is_a?(Array)
            raise WrongOption.new("Serializable fields must be an array")
          end
        end
      end
    end
  end
end
