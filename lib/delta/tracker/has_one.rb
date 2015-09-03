module Delta
  class Tracker
    class HasOne < Association
      # TODO: handle build_#{assoc_name}=
      def track!
        ["#{@name}=", "create_#{@name}"].each do |method|
          @trackable_class.class_eval %Q{
            def #{method}(*args, &block)
              super(*args, &block).tap do |obj|
                return unless obj.persisted?
                delta_association_change('#{@name}', obj)
              end
            end
          }
        end
      end
    end
  end
end
