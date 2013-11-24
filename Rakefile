$LOAD_PATH.unshift(File.expand_path("../lib", __FILE__))

require "bundler/gem_tasks"
require "active_record"
require "fileutils"

ENV["RACK_ENV"] ||= "development"

require "deep_thought"

DeepThought.setup(ENV)

require "deep_thought/tasks"

namespace :db do
  desc 'Output the schema to db/schema.rb'
  task :schema do
    ActiveRecord::Schema.verbose = true
    File.open('db/schema.rb', 'w') do |f|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, f)
    end
  end

  desc "Create a migration at ./db/migrate/{NAME}"
  task :create_migration do
    name = ENV['NAME']
    abort("No name specified. Use `rake db:create_migration NAME=migration_name`") if !name

    migrations_dir = File.join("db", "migrate")
    version = ENV["VERSION"] || Time.now.utc.strftime("%Y%m%d%H%M%S")
    filename = "#{version}_#{name}.rb"
    migration_name = name.gsub(/_(.)/) { $1.upcase }.gsub(/^(.)/) { $1.upcase }

    FileUtils.mkdir_p(migrations_dir)

    open(File.join(migrations_dir, filename), 'w') do |f|
      f << (<<-EOS).gsub("      ", "")
      class #{migration_name} < ActiveRecord::Migration
        def up
        end

        def down
        end
      end
      EOS
    end

    puts "New migration created at #{migrations_dir}/#{filename}"
  end
end
