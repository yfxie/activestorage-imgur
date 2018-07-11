module ActiveStorageImgur
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    source_root File.expand_path('../templates', __FILE__)
    desc "Add the migrations for DoubleDouble"

    def self.next_migration_number(path)
      next_migration_number = current_migration_number(path) + 1
      ActiveRecord::Migration.next_migration_number(next_migration_number)
    end

    def copy_migrations
      migration_template "create_active_storage_imgur_key_mappings.rb",
                         "db/migrate/create_active_storage_imgur_key_mappings.rb"
    end
  end
end
