require 'ap'

module Delta
  module Adapter
    class ActiveRecord
      def initialize(model, changes)
        @model   = model
        @changes = changes
      end

      def persist!
        ap({
          model_type: @model.class.name,
          model_id:   @model.id,
          delta:      @changes
        })
      end
    end
  end
end
