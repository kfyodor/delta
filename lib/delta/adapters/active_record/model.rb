module Delta
  module Adapter
    module ActiveRecord
      def self.register(model)
        model.send :include, Ext
      end

      module Ext
        def self.included(base)
          klass_name = "Delta::Adapter::ActiveRecord::Model"
          _scope     = -> { order('created_at').includes(:user) }

          base.has_many :deltas, _scope,
                        class_name: klass_name,
                        as: :model
        end
      end

      class Model < ::ActiveRecord::Base
        self.table_name = "deltas"

        scope :newest, -> { reorder('created_at desc') }

        belongs_to :model, polymorphic: true
        belongs_to :user

        def readonly?
          persisted?
        end

        def each_change(&block)
          object.each do |change|
            block.call OpenStruct.new(change)
          end
        end
      end
    end
  end
end
