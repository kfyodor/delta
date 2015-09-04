module Delta
  module Controller
    def self.included(base)
      base.class_eval do
        prepend_before_filter do
          m = Delta.config.controller_user_method
          Delta.current_user = send(m) if self.respond_to?(m)
        end
      end
    end
  end
end
