module Delta
  module Adapter
    module ActiveRecord
      def self.register(model)
        model.send :include, Ext
      end

      module Ext
        def self.included(base)
          base.has_many :deltas,
            -> { order('created_at') },
            class_name: "Delta::Adapter::ActiveRecord::Model",
            as: :model
        end
      end

      class Model < ::ActiveRecord::Base
        self.table_name = "deltas"

        belongs_to :model, polymorphic: true
        belongs_to :user

        def readonly?
          persisted?
        end
      end
    end
  end
end
