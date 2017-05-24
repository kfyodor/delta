$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

ENV['RAILS_ENV'] = 'test'

require 'rails/all'
require 'test_app/application'
require 'delta'

require 'rspec/rails'

TestApp::Application.initialize!

require File.expand_path('spec/test_app/db/schema.rb')
require File.expand_path('lib/generators/delta/templates/create_deltas.rb')

CreateDeltas.new.change

RSpec.configure do |c|
  c.use_transactional_fixtures = true
end
