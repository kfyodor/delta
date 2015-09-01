# TODO: refactor this chaos ASAP
module Delta
  class Tracker
    attr_reader :attributes,
                :has_many_associations,
                :has_one_associations,
                :belongs_to_associations

    def initialize(klass, field_names, options = {})
      @klass       = klass
      @field_names = field_names.map(&:to_s)
      @options     = options

      @has_many_associations   = {}
      @belongs_to_associations = {}
      @has_one_associations    = {}

      @attributes   = {}
      @deltas_cache = []

      build_attributes
      build_associations
    end

    def track!
      @has_many_associations.each do |assoc_name, reflection|
        @klass.class_eval do
          key = reflection.association_primary_key
          send("after_add_for_#{assoc_name}").<< ->(_, model, assoc){
            model.class.delta_tracker.send :persist_or_cache!, model, {
              name: assoc_name,
              action: "A",
              timestamp: Time.now.to_i,
              object: { key => assoc.send(key) }
            }
          }

          send("after_remove_for_#{assoc_name}").<< ->(_, model, assoc){
            model.class.delta_tracker.send :persist_or_cache!, model, {
              name: assoc_name,
              action: "R",
              timestamp: Time.now.to_i,
              object: { key => assoc.send(key) }
            }
          }
        end
      end

      @has_one_associations.each do |assoc_name, reflection|
        key = reflection.association_primary_key
        # TODO build_#{assoc}

        ["#{assoc_name}=", "create_#{assoc_name}"].each do |method|
          @klass.class_eval %Q{
            def #{method}(*args, &block)
              super(*args, &block).tap do |assoc|
                return unless assoc.persisted?

                self.class.delta_tracker.send :persist_or_cache!, self, {
                  name: "#{assoc_name}",
                  action: "C",
                  timestamp: Time.now.to_i,
                  object: { "#{key}" => assoc.send("#{key}") }
                }
              end
            end
          }
        end
      end

      # Track attributes and belongs_to assocs via AM::Dirty
      @klass.class_eval do
        after_update do
          self.class.delta_tracker.send :persist_attrs!, self
        end

        after_commit do
          self.class.delta_tracker.send :reset_deltas_cache!
        end
      end
    end

    private

    def persist_attrs!(model)
      ts     = Time.now.to_i
      deltas = []

      return if model.changes.empty?

      @attributes.keys.each do |col|
        next unless changed_column = model.changes[col]

        deltas << {
          name: col,
          action: "C",
          timestamp: ts,
          object: changed_column.last
        }
      end

      # TODO: polymorphic
      @belongs_to_associations.each do |name, reflection|
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

      @deltas_cache += deltas

      if model.persisted?
        Delta.config.adapters.each do |adapter|
          "#{adapter}::Store"
            .constantize
            .new(model, @deltas_cache)
            .persist!
        end

        reset_deltas_cache!
      end
    end

    def reset_deltas_cache!
      @deltas_cache = []
    end

    def build_attributes
      @attributes = @klass.columns_hash.select do |k, _|
        @field_names.include? k
      end
    end

    def build_associations
      @klass.reflections.each do |assoc_name, reflection|
        if @field_names.include?(assoc_name)
          case reflection.macro
          when :has_many
            @has_many_associations[assoc_name] = reflection
          when :belongs_to
            @belongs_to_associations[assoc_name] = reflection
          when :has_one
            @has_one_associations[assoc_name] = reflection
          end
        end
      end
    end
  end
end
