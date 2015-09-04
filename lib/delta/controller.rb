module Delta
  module Controller
    def self.included(base)
      base.class_eval do
        prepend_before_filter do
          m = Delta.config.controller_user_method
          begin
            Delta.current_user = send(m) if self.respond_to?(m)
          rescue => e
            Rails.logger.error "[]Delta] Error in controller user method: #{e.class} #{e.message}"
            nil
          end
        end
      end
    end
  end
end
