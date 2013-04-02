require "deep_thought/app"
require "deep_thought/version"

module DeepThought
  def self.app
    @app ||= Rack::Builder.app {
      map '/' do
        run DeepThought::App
      end
    }
  end
end
