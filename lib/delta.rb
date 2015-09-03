require 'delta/version'

require 'delta/config/adapters'
require 'delta/config'

require 'delta/tracking'

require 'delta/tracker'
require 'delta/tracker/association'
require 'delta/tracker/has_many'
require 'delta/tracker/has_one'

require 'delta/tracker/model_ext'

require 'delta/adapter'

require 'delta/controller'

require 'request_store'

# TODO:
#   - track associations added via build_assoc. we need to cache them and then somehow
#     get their data from model.association_cache???
#   - customize user model name
#   - customize associations columns for serialization
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

    def current_user=(user)
      store[:current_user] = user
    end

    def current_user
      store[:current_user]
    end

    def store
      @store ||= RequestStore.store
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
end

if defined?(ActiveRecord) && defined?(ActiveRecord::Base)
  ActiveRecord::Base.send :include, Delta::Tracking
end

if defined?(ActionController) && defined?(ActionController::Base)
  ActionController::Base.send :include, Delta::Controller
end
