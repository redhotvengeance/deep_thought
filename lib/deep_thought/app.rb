require 'sinatra'

module DeepThought
  class App < Sinatra::Base
    get '/' do
      "hello world"
    end
  end
end
