require 'httparty'
require 'deep_thought/ci_service/ci_service'

module DeepThought
  module CIService
    class Travis < DeepThought::CIService::CIService
      def is_branch_green?(app, branch, *args)
        is_green = false

        response = HTTParty.get("#{@endpoint}/repos/#{app}/branches/#{branch}")
        build = JSON.parse(response.body)

        if build['branch']['state'] == 'passed'
          return true
        end
        return false
      end
    end
  end
end
