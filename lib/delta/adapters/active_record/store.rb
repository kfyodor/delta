module Delta
  module Adapter
    module ActiveRecord
      class Store
        def initialize(model, changes)
          @model   = model
          @changes = changes
        end

        def persist!
          @model.deltas.create attrs
        end

        def attrs
          @attrs ||= {
            object: @changes,
            profile: Delta.current_profile
          }
        end
      end
    end
  end
end
