require 'delta/version'
require 'delta/config'
require 'delta/tracking'
require 'delta/changes'
require 'delta/adapter'

require 'thread'

# TODO:
#   - belongs_to relationships
#   - controller helpers for current_user
#   - customize associations columns
#   - different persistance options: redis, queue, kafka, whatever (active record is default)

module Delta
  class << self
    attr_accessor :config

    def config
      @config ||= Config.new
    end

    def configure
      yield(config)
    end
  end
end

ActiveRecord::Base.send :include, Delta::Tracking
