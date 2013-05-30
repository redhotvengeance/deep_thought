require 'httparty'

module DeepThought
  module Scaler
    def self.scale
      if (ENV['RACK_ENV'] != 'development' && ENV['RACK_ENV'] != 'test') && (ENV['HEROKU_APP'] && ENV['HEROKU_APP'] != '') && (ENV['HEROKU_API_KEY'] && ENV['HEROKU_API_KEY'] != '')
        if Delayed::Job.count > 0
          scale_up
        else
          scale_down
        end
      end
    end

    private

    def self.scale_up
      options = {:body => {:type => 'worker', :qty => '1'}, :basic_auth => {:username => '', :password => ENV['HEROKU_API_KEY']}}
      HTTParty.post("https://api.heroku.com/apps/#{ENV['HEROKU_APP']}/ps/scale", options)
    end

    def self.scale_down
      options = {:body => {:type => 'worker', :qty => '0'}, :basic_auth => {:username => '', :password => ENV['HEROKU_API_KEY']}}
      HTTParty.post("https://api.heroku.com/apps/#{ENV['HEROKU_APP']}/ps/scale", options)
    end

    Delayed::Backend::ActiveRecord::Job.class_eval do
      after_destroy :after_destroy

      def after_destroy
        DeepThought::Scaler.scale
      end
    end
  end
end
