module Delta
  class DeltaRailtie < ::Rails::Railtie
    config.after_initialize do
      if defined?(ActiveRecord) && defined?(ActiveRecord::Base)
        ActiveRecord::Base.send :include, Delta::Tracking
      else
        raise "You can't use Delta without ActiveRecord."
      end

      if defined?(ActionController) && defined?(ActionController::Base)
        ActionController::Base.send :include, Delta::Controller
      end
    end
  end
end
