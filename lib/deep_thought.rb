require "deep_thought/app"
require "deep_thought/deploy"
require "deep_thought/version"

module DeepThought
  def self.app
    @app ||= Rack::Builder.app {
      map '/' do
        run DeepThought::App
      end

      map '/deploy/' do
        run DeepThought::Deploy
      end
    }
  end
end
