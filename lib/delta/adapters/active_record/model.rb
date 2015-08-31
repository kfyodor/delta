module Delta
  module Adapter
    module ActiveRecord
      def self.register(model)
        model.send :include, Ext
      end

      module Ext
        def self.included(base)
          base.has_many :deltas,
            class_name: "Delta::Adapter::ActiveRecord::Model",
            as: :model
        end
      end

      class Model < ::ActiveRecord::Base
        self.table_name = "deltas"

        belongs_to :model, polymorphic: true

        def readonly?
          persisted?
        end
      end

      Delta::Tracking.models.each { |m| m.send :include, Ext }
    end
  end
end
