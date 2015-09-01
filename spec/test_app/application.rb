module TestApp

  TEST_APP_PATH = File.expand_path("../", __FILE__)

  class Application < Rails::Application
    config.action_controller.allow_forgery_protection = false
    config.action_controller.perform_caching = false
    config.action_dispatch.show_exceptions = false
    config.active_support.deprecation = :stderr
    config.active_support.test_order = :random
    config.assets.enabled = true
    config.cache_classes = true
    config.consider_all_requests_local = true
    config.eager_load = false
    config.encoding = "utf-8"
    config.active_record.raise_in_transactional_callbacks = true

    config.paths["app/controllers"] << "#{TEST_APP_PATH}/controllers"
    config.paths["app/models"] << "#{TEST_APP_PATH}/models"
    config.paths["config/database"] = "#{TEST_APP_PATH}/config/database.yml"
    config.paths["config/routes.rb"] << "#{TEST_APP_PATH}/config/routes.rb"
    config.paths["db"] << "#{TEST_APP_PATH}/db"

    config.secret_key_base = "SECRET_KEY_BASE"
    config.secret_token = "HERE_S_MY_LOOOOOOOOONG_SECRET_TOKEN"

    null_logger = Logger.new("/dev/null")
    Rails.logger = null_logger
    ActiveRecord::Base.logger = null_logger
  end
end
