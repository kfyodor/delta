module Delta
  class Tracker
    def initialize(klass, options = {})
      @trackable_class  = klass
      @trackable_fields = {}
      @options          = options
    end

    def track!
      @trackable_class.class_eval { include ModelExt }
    end

    def add_trackable_fields(fields)
      fields.map(&:to_s).each do |field_name|
        add_trackable_field(field_name)
      end
    end

    def add_trackable_field(field_name, opts = {})
      assert_unique_field!(field_name)

      if attr = @trackable_class.columns_hash[field_name]
        add_attribute(field_name, attr, opts)
      elsif reflection = @trackable_class.reflections[field_name]
        add_association(field_name, reflection, opts)
      else
        raise NonTrackableField.new(field_name)
      end
    end

    %w[
      attributes
      has_many_associations
      has_one_associations
      belongs_to_associations
    ].each do |m|
      define_method m do
        @trackable_fields[m.to_sym] || {}
      end
    end

    def trackable_fields
      if @trackable_fields.empty?
        {}
      else
        @trackable_fields.values.reduce :merge
      end
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

    def add_attribute(field_name, attr, opts)
      @trackable_fields[:attributes] ||= {}
      @trackable_fields[:attributes][field_name] = Attribute.create(
        field_name,
        attr,
        opts
      )
    end

    def add_association(field_name, reflection, opts = {})
      key   = "#{reflection.macro}_associations".to_sym
      klass = case reflection.macro
              when :has_many
                HasMany
              when :has_one
                HasOne
              when :belongs_to
                BelongsTo
              else
                raise UnsupportedAssotiationType.new(field_name)
              end

      @trackable_fields[key] ||= {}

      @trackable_fields[key][field_name] = klass.create(
        @trackable_class,
        field_name,
        reflection,
        opts
      )
    end

    def assert_unique_field!(field_name)
      raise FieldAlreadyAdded.new(field_name) if trackable_fields[field_name]
    end
  end
end
