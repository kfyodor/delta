module Delta
  class Tracker
    class HasMany < Association
      def track!
        actions = ["add", "remove"]

        if @opts[:only].is_a?(Array)
          actions = @opts[:only].map(&:to_s) & actions
        end

        actions.each do |action|
          @trackable_class.class_eval %Q{
            send("after_#{action}_for_#{@name}").<< ->(_, model, obj) {
              model.delta_association_#{action}('#{@name}', obj)
            }
          }
        end

        super
      end
    end
  end
end
