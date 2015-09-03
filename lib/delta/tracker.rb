module Delta
  class Tracker
    def initialize(klass, field_names, options = {})
      @trackable_class  = klass
      @field_names      = field_names.map(&:to_s)
      @trackable_fields = {}
      @options          = options
    end

    def track!
      @trackable_class.send :include, ModelExt

      build_trackable_fields

      @trackable_class.class_eval do
        after_update { persist_delta_fields! }
        after_commit { reset_deltas_cache! }
      end
    end

    def attributes
      @trackable_fields[:attributes]
    end

    def belongs_to_associations
      @trackable_fields[:belongs_to_associations]
    end

    def persist!(model, deltas)
      deltas = [deltas] unless deltas.is_a?(Array)

      model.cache_deltas(deltas)

      if model.persisted?
        Delta.config.adapters.each do |adapter|
          "#{adapter}::Store"
            .constantize
            .new(model, model.deltas_cache)
            .persist!
        end

        model.reset_deltas_cache!
      end
    end

    private

    def build_trackable_fields
      @field_names.each do |field_name|
        add_trackable_field(field_name)
      end
    end

    def add_trackable_field(field_name)
      if attr = @trackable_class.columns_hash[field_name]
        add_attribute(field_name, attr)
      elsif reflection = @trackable_class.reflections[field_name]
        add_association(field_name, reflection)
      else
        raise NonTrackableField.new(field_name)
      end
    end

    def add_attribute(field_name, attr)
      @trackable_fields[:attributes] ||= {}
      @trackable_fields[:attributes][field_name] = attr
    end

    def add_association(field_name, reflection)
      case reflection.macro
      when :has_many
        HasMany.create(@trackable_class, field_name, reflection)
      when :has_one
        HasOne.create(@trackable_class, field_name, reflection)
      when :belongs_to
        @trackable_fields[:belongs_to_associations] ||= {}
        @trackable_fields[:belongs_to_associations][field_name] = reflection
      else
        raise UnsupportedAssotiationType.new(field_name)
      end
    end
  end
end
