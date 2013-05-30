require 'httparty'

module DeepThought
  module Notifier
    def self.notify(user, message)
      begin
        HTTParty.post("#{user.notification_url}", :body => {:message => message}.to_json, :headers => {'Content-Type' => 'application/json'})
      rescue
        'poop'
      end
    end
  end
end
