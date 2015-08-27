require 'rails/generators/base'
require 'rails/generators/active_record'

module Delta
  module Generators
    class CreateTableGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("../templates", __FILE__)

      def self.next_migration_number(dirname)
        ::ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      def copy_migration
        migration_template "create_deltas.rb", "db/migrate/create_deltas.rb"
      end
    end
  end
end
