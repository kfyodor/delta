module Delta
  class Railtie < ::Rails::Railtie
    config.after_initialize do
      if defined?(ActionController) && defined?(ActionController::Base)
        ActionController::Base.send :include, Delta::Controller
      end
    end
  end
end
