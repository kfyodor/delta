require 'delta/version'

require 'delta/config/adapters'
require 'delta/config'

require 'delta/tracking'
require 'delta/tracker'
require 'delta/adapter'

require 'delta/controller'

require 'request_store'

# TODO:
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
end

if defined?(ActiveRecord) && defined?(ActiveRecord::Base)
  ActiveRecord::Base.send :include, Delta::Tracking
end

if defined?(ActionController) && defined?(ActionController::Base)
  ActionController::Base.send :include, Delta::Controller
end
