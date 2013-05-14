require "bundler/gem_tasks"
require "dotenv/tasks"
require "active_record"
require "fileutils"
require "./lib/deep_thought"

task :environment, [:env] => :dotenv do |t, args|
  if args[:env]
    ENV['RACK_ENV'] = args[:env]
  end

  puts "RACK_ENV: #{ENV['RACK_ENV']}"

  DeepThought.setup(ENV)
end

desc "Create a user"
task :create_user, [:email, :password] => [:environment] do |t, args|
  user = DeepThought::User.create(:email => "#{args[:email]}", :password => "#{args[:password]}", :password_confirmation => "#{args[:password]}")

  if user.errors.count > 0
    puts "Error when creating new user: #{user.errors.messages}"
  else
    puts "Created new user with email: #{user.email}."
  end
end

namespace :jobs do
  desc "Start a delayed_job worker"
  task :work => [:environment] do
    Delayed::Worker.new(:min_priority => ENV['MIN_PRIORITY'], :max_priority => ENV['MAX_PRIORITY']).start
  end

  desc "Clear the delayed_job queue"
  task :clear => [:environment] do
    Delayed::Job.delete_all
  end
end

namespace :db do
  desc "Migrate the database"
  task :migrate, [:env] => :environment do |t, args|
    ActiveRecord::Migrator.migrate('db/migrate')
  end

  desc "Rolls the schema back to the previous version"
  task :rollback, [:env] => :environment do |t, args|
    ActiveRecord::Migrator.rollback('db/migrate', 1)
  end

  desc 'Reset the database'
  task :reset, [:env] => :environment do |t, args|
    ActiveRecord::Migrator.down('db/migrate')
    ActiveRecord::Migrator.migrate('db/migrate')
  end

  desc 'Output the schema to db/schema.rb'
  task :schema, [:env] => :environment do |t, args|
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
