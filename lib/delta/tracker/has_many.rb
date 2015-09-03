module Delta
  class Tracker
    class HasMany < Association
      def track!
        %w(add remove).each do |action|
          @trackable_class.class_eval %Q{
            send("after_#{action}_for_#{@name}").<< ->(_, model, obj) {
              model.delta_association_#{action}('#{@name}', obj)
            }
          }
        end
      end
    end
  end
end
