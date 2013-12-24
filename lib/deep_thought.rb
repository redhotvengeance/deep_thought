require 'active_record'
require 'delayed_job_active_record'

require 'deep_thought/app'
require 'deep_thought/api'
require 'deep_thought/models/deploy'
require 'deep_thought/models/project'
require 'deep_thought/models/state'
require 'deep_thought/models/user'
require 'deep_thought/deployer'
require 'deep_thought/deployer/shell'
require 'deep_thought/ci_service'
require 'deep_thought/ci_service/janky'
require 'deep_thought/ci_service/travis'
require 'deep_thought/notifier'
require 'deep_thought/scaler'
require 'deep_thought/version'

module DeepThought
  def self.setup(settings)
    env = settings['RACK_ENV'] ||= 'development'

    if env != "production"
      settings["DATABASE_URL"] ||= "postgres://deep_thought@localhost/deep_thought_#{env}"
    end

    database = URI(settings["DATABASE_URL"])
    settings["DATABASE_ADAPTER"] ||= "postgresql"

    connection = {
      :adapter   => settings["DATABASE_ADAPTER"],
      :encoding  => "utf8",
      :database  => database.path[1..-1],
      :pool      => 5,
      :username  => database.user,
      :password  => database.password,
      :host      => database.host,
      :port      => database.port
    }

    ActiveRecord::Base.establish_connection(connection)

    BCrypt::Engine.cost = 12

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

  DeepThought::Deployer.register_adapter('shell', DeepThought::Deployer::Shell)
  DeepThought::CIService.register_adapter('janky', DeepThought::CIService::Janky)
  DeepThought::CIService.register_adapter('travis', DeepThought::CIService::Travis)
end
