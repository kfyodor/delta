module Delta
  class Tracker
    class Association < TrackableField
      class WrongOption < Exception; end

      ### Temp stuff - gotta think about this
      class ReflectionNotFound          < Exception; end
      class ManyToManyNotSupported      < Exception; end
      class WrongReverseReflectionModel < Exception; end
      ###


      def initialize(trackable_class, name, reflection, opts = {})
        @trackable_class = trackable_class
        @name            = name
        @reflection      = reflection
        @opts            = build_opts(opts)
      end

      def track!
        track_association_change! if @opts[:notify]
      end

      def serialize(obj, action)
        key        = obj.class.primary_key
        serialized = { key => obj.send(key) }

        @opts[:serialize].each do |f|
          serialized[f] = obj.send(f)
        end

        {
          name: @name,
          action: action,
          timestamp: Time.now.to_i,
          object: serialized
        }
      end

      # Track assoc changes only when assoc has_one/belongs_to main model
      # need to think how to track all association changes without
      # loosing the main idea and without huge performance bottlenecks.
      # And also think about tracking changes of polymorphic assocs.
      def serialize_change(obj)
        if (obj.changes.keys & @opts[:serialize]).any?
          serialize(obj, "C")
        end
      end

      def track_association_change!
        assoc = if @opts[:notify] == true
                  @trackable_class.model_name.singular
                else
                  @opts[:notify].to_s
                end

        r = @reflection.klass.reflections[assoc]

        raise ReflectionNotFound          unless r
        raise ManyToManyNotSupported      unless [:has_one, :belongs_to].include?(r.macro)
        raise WrongReferseReflectionModel unless r.klass == @trackable_class

        @reflection.klass.class_eval %{
          after_update do
            t     = #{@trackable_class}.delta_tracker
            delta = t.trackable_fields['#{@name}'].serialize_change(self)
            model = send('#{assoc}')

            t.persist!(model, delta) if delta
          end
        }
      end

      private

      # TODO: Come up with something smarter :)
      def build_opts(opts)
        {}.tap do |o|
          o[:serialize] = if opts[:serialize] && opts[:serialize].is_a?(Array)
            opts[:serialize].map(&:to_s)
          else
            []
          end

          o[:only]   = opts[:only] || ["add", "remove"]
          o[:notify] = opts[:notify] || false
        end
      end
    end
  end
end
