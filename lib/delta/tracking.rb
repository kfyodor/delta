require 'thread'

module Delta
  module Tracking

    @@models = Set.new
    @@lock   = Mutex.new

    class << self
      def included(base)
        base.extend ClassMethods
      end

      def models
        @@models
      end

      def add_model(model)
        @@lock.synchronize do
          @@models << model
        end
      end
    end

    module ClassMethods
      def track_deltas(*fields)
        field_names  = fields.map &:to_s
        filter_proc  = ->(k, _) { field_names.include? k }

        class_eval do
          class_attribute :delta_associations
          class_attribute :delta_columns

          self.delta_columns      = columns_hash.select(&filter_proc)
          self.delta_associations = reflections.select(&filter_proc)
        end

        Tracking.add_model(self)
        send :include, Changes

        delta_associations.each do |assoc_name, reflection|
          case reflection.macro
          when :has_many
            track_has_many_association(assoc_name)
          when :belongs_to
            puts "TODO Belongs to!"
          end
        end
      end

      private

      def track_has_many_association(assoc_name)
        self.send("after_add_for_#{assoc_name}").<< ->(_, model, assoc) {

          model.cache_association_delta!({
            name:      assoc_name,
            action:    'A',
            timestamp: Time.now.to_i,
            type:      'A',
            object:    { id: assoc.id } # TODO customize additional fields
          })
        }

        self.send("after_remove_for_#{assoc_name}").<< ->(_, model, assoc) {
          model.cache_association_delta!({
            name:      assoc_name,
            action:    'R',
            timestamp: Time.now.to_i,
            type:      'A',
            object:    { id: assoc.id }
          })
        }
      end
    end
  end
end
