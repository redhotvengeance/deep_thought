require "rake"
require "rake/tasklib"
require "active_record"

module DeepThought
  module Tasks
    extend Rake::DSL

    desc "Create a user"
    task :create_user, [:email, :password] do |t, args|
      user = DeepThought::User.create(:email => "#{args[:email]}", :password => "#{args[:password]}", :password_confirmation => "#{args[:password]}")

      if user.errors.count > 0
        puts "Error when creating new user: #{user.errors.messages}"
      else
        puts "Created new user with email: #{user.email}."
      end
    end

    namespace :jobs do
      desc "Start a delayed_job worker"
      task :work do
        Delayed::Worker.new(:min_priority => ENV['MIN_PRIORITY'], :max_priority => ENV['MAX_PRIORITY']).start
      end

      desc "Get number of jobs in the delayed_job queue"
      task :count do
        puts Delayed::Job.count
      end

      desc "Clear the delayed_job queue"
      task :clear do
        Delayed::Job.delete_all
      end
    end

    namespace :db do
      desc "Migrate the database"
      task :migrate do
        ActiveRecord::Migration.verbose = true
        ActiveRecord::Migrator.migrate(db("migrate"))
      end

      desc "Rolls the schema back to the previous version"
      task :rollback do
        ActiveRecord::Migration.verbose = true
        ActiveRecord::Migrator.rollback(db("migrate"), 1)
      end

      desc 'Reset the database'
      task :reset do
        ActiveRecord::Migration.verbose = true
        ActiveRecord::Migrator.down(db("migrate"))
        ActiveRecord::Migrator.migrate(db("migrate"))
      end
    end

    private

    def self.db(action = '')
      @db ||= Pathname(__FILE__).expand_path.join("../../../db")
      @db.join(action).to_s
    end
  end
end
