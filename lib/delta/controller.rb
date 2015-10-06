module Delta
  module Controller
    def self.included(base)
      base.class_eval do
        before_action do
          Delta.set_current_user_proc ->{
            begin
              self.send Delta.config.controller_user_method
            rescue => e
              Rails.logger.info "[Delta] Unable to get current " +
                                "user (#{e.class}: #{e.message})"
              nil
            end
          }
        end
      end
    end
  end
end
