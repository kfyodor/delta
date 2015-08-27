require 'delta/version'
require 'delta/config'
require 'delta/tracking'
require 'delta/adapter'
require 'delta/changes'

# TODO:
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

ActiveRecord::Base.send :include, Delta::Tracking ## Railtie?

# VERSION
### CREATED_AT timestamp
### USER_ID    integer
### CHANGES    {}json
### MODEL_TYPE string
### MODEL_ID   integer

# DIFF
### ACTION:  [A]dd, [C]hange, [R]emove
### TYPE:    [C]olumn, [A]ssociation
### NAME:    column or association name
### OBJECT:  value or {id, + custom attrs}json
