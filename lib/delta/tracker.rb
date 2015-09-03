# TODO: refactor this chaos ASAP
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

      # Track attributes and belongs_to assocs via AM::Dirty
      @trackable_class.class_eval do
        after_update do
          self.class.delta_tracker.send :persist_attrs!, self
        end

        after_commit { reset_deltas_cache! }
      end
    end

    private

    def persist_attrs!(model)
      ts     = Time.now.to_i
      deltas = []

      return if model.changes.empty?

      @trackable_fields[:attributes].keys.each do |col|
        next unless changed_column = model.changes[col]

        deltas << {
          name: col,
          action: "C",
          timestamp: ts,
          object: changed_column.last
        }
      end

      # TODO: polymorphic
      @trackable_fields[:belongs_to_associations].each do |name, reflection|
        key = reflection.foreign_key

        next unless changed_assoc = model.changes[key]

        deltas << {
          name: name,
          action: "C",
          timestamp: ts,
          object: { reflection.association_primary_key => changed_assoc.last }
        }
      end

      return if deltas.empty?

      persist_or_cache!(model, deltas)
    end

    # move to instance
    def persist_or_cache!(model, deltas)
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
      key   = "#{reflection.macro}_associations".to_sym
      klass = case reflection.macro
              when :has_many
                HasMany
              when :has_one
                HasOne
              end

      @trackable_fields[key] ||= {}
      @trackable_fields[key][field_name] = if klass
                                             klass.create(@trackable_class, field_name, reflection)
                                           else
                                             reflection
                                           end
    end

    def assert_reflection_macro!(field_name, reflection)
      unless [:has_many, :belongs_to, :has_one].include?(reflection.macro)
        raise UnsupportedAssotiationType.new(field_name)
      end
    end
  end
end
