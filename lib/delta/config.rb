require 'set'
require 'thread'

module Delta
  class Config
    attr_reader   :adapters

    attr_accessor :controller_user_method,
                  :user_model,
                  :dont_use_after_commit_callbacks

    def initialize
      @adapters                        = Adapters.new(["active_record"])
      @user_model                      = :user
      @dont_use_after_commit_callbacks = false
      @controller_user_method          = :current_user
    end

    def adapters=(adapter_names)
      @adapters = Adapters.new(adapter_names)
    end
  end
end
