require 'delta/adapters/active_record/model'
require 'delta/adapters/active_record/store'

module Delta
  module Adapter
    module ActiveRecord
      def self.register(model)
        model.send :include, Ext
      end
    end
  end
end
