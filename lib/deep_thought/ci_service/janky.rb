require 'httparty'
require 'deep_thought/ci_service/ci_service'

module DeepThought
  module CIService
    class Janky < DeepThought::CIService::CIService
      def is_branch_green?(app, branch, hash)
        is_green = false

        response = HTTParty.get("#{@endpoint}/_hubot/#{app}/#{branch}", {:basic_auth => {:username => @username, :password => @password}})
        builds = JSON.parse(response.body)

        builds.each do |build|
          if build['sha1'].to_s == hash.to_s
            if build['green']
              is_green = true
            end

            break
          end
        end

        is_green
      end
    end
  end
end
