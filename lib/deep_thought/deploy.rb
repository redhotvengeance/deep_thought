require 'sinatra'

module DeepThought
  class Deploy < Sinatra::Base
    get '/' do
      "deploying x to y"
    end
  end
end
