require "bundler/gem_tasks"
require 'dotenv/tasks'
require "active_record"
require "./lib/deep_thought"

task :environment => :dotenv do
  puts "RACK_ENV: #{ENV['RACK_ENV']}"
  
  DeepThought.setup(ENV)
end

namespace :db do
  desc "Migrate the database"
  task :migrate => :environment do
    ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end

  desc "Rolls the schema back to the previous version"
  task :rollback => :environment do
    ActiveRecord::Migrator.rollback('db/migrate', 1)
  end
end
