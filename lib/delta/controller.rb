module Delta
  module Controller
    def self.included(base)
      base.class_eval do
        prepend_before_filter do
          Delta.current_user = send(Delta.config.controller_user_method)
        end

        after_filter do
          Delta.current_user = nil
        end
      end
    end
  end
end
