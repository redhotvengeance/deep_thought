require 'httparty'

module DeepThought
  module Notifier
    include HTTParty

    class << self
      def notify(user, message)
        HTTParty.post("#{user.notification_url}", :body => {:message => message}.to_json, :headers => {'Content-Type' => 'application/json'})
      end

      handle_asynchronously :notify
    end
  end
end
