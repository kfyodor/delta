require 'delta/version'

require 'delta/config/adapters'
require 'delta/config'

require 'delta/tracking'

require 'delta/tracker'
require 'delta/tracker/trackable_field'
require 'delta/tracker/attribute'
require 'delta/tracker/association'
require 'delta/tracker/has_many'
require 'delta/tracker/has_one'
require 'delta/tracker/belongs_to'

require 'delta/tracker/model_ext'

require 'delta/adapter'

require 'delta/controller'

require 'request_store'

if defined?(Rails)
  require 'delta/railtie'
end

# TODO:
#   - track associations added via build_assoc. we need to cache them and then somehow
#   - customize user model name
#   - different persistance options: redis, mq, kafka, whatever (active record is default)

module Delta
  class << self
    @@config = Config.new

    def config
      @@config
    end

    def configure
      yield(config)
    end

    def current_profile
      current_profile_proc && current_profile_proc.call
    end

    def store
      RequestStore
    end

    def set_current_profile_proc(proc)
      store[:current_profile_proc] = proc
    end

    private

    def current_profile_proc
      store[:current_profile_proc]
    end
  end

  class UnsupportedAssotiationType < Exception
    def initialize(field_name)
      @message = "Unsupported association macro for `#{field_name}`"
    end
  end

  class NonTrackableField < Exception
    def initialize(field_name)
      @message = "`#{field_name}` is not an attribute or association"
    end
  end

  class FieldAlreadyAdded < Exception
    def initialize(field_name)
      @message = "`#{field_name}` is already trackable"
    end
  end
end

if defined?(ActiveRecord) && defined?(ActiveRecord::Base)
  ActiveRecord::Base.send :include, Delta::Tracking
else
  raise "You can't use Delta without ActiveRecord."
end
