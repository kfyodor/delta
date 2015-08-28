module Delta
  module Adapter
    module ActiveRecord
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
      end

      Delta::Tracking.models.each { |m| m.send :include, Ext }
    end
  end
end
