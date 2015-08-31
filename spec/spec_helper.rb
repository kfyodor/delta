$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'active_record'
require 'delta'

config = YAML.load_file(File.expand_path('../config/database.yml', __FILE__))['test']

ActiveRecord::Base.establish_connection config

ActiveRecord::Tasks::DatabaseTasks.load_schema_for(
  config,
  :ruby,
  File.expand_path("../config/schema.rb", __FILE__)
)

require File.expand_path('lib/generators/delta/templates/create_deltas.rb')
CreateDeltas.new.change

Dir[File.expand_path('../models/*.rb', __FILE__)].each { |f| require f }

RSpec.configure do |c|
  c.around do |ex|
    ActiveRecord::Base.transaction do
      ex.run
      raise ActiveRecord::Rollback
    end
  end
end
