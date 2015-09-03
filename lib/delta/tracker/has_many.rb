module Delta
  class Tracker
    class HasMany
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
        %w(add remove).each do |action|
          @trackable_class.class_eval %Q{
            send("after_#{action}_for_#{@name}").<< ->(_, model, obj) {
              model.delta_after_#{action}('#{@name}', '#{key}', obj)
            }
          }
        end
      end

      private

      def key
        @key ||= @reflection.association_primary_key
      end
    end
  end
end
