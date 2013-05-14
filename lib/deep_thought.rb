require "active_record"
require "delayed_job_active_record"

require "deep_thought/app"
require "deep_thought/api"
require "deep_thought/models/deploy"
require "deep_thought/models/project"
require "deep_thought/models/state"
require "deep_thought/models/user"
require "deep_thought/deployer"
require "deep_thought/deployer/capistrano"
require 'deep_thought/ci_service'
require 'deep_thought/ci_service/janky'
require "deep_thought/version"

module DeepThought
  def self.setup(settings)
    env = settings['RACK_ENV']

    if env != "production"
      settings["DATABASE_URL"] ||= "postgres://deep_thought@localhost/deep_thought_#{env}"
    end

    database = URI(settings["DATABASE_URL"])

    connection = {
      :adapter   => "postgresql",
      :encoding  => "unicode",
      :database  => database.path[1..-1],
      :pool      => 5,
      :username  => database.user,
      :password  => database.password
    }

    ActiveRecord::Base.establish_connection(connection)

    if settings['CI_SERVICE']
      DeepThought::CIService.setup(settings)
    end
  end

  def self.app
    @app ||= Rack::Builder.app {
      map '/' do
        run DeepThought::App
      end

      map '/deploy/' do
        run DeepThought::Api
      end
    }
  end

  DeepThought::Deployer.register_adapter('capistrano', DeepThought::Deployer::Capistrano)
  DeepThought::CIService.register_adapter('janky', DeepThought::CIService::Janky)
end
