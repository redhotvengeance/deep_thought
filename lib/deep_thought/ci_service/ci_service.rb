module DeepThought
  module CIService
    class CIService
      attr_accessor :endpoint, :username, :password

      def initialize
        if self.class.name == 'DeepThought::CIService::CIService'
          raise "#{self.class.name} is abstract, you cannot instantiate it directly."
        end
      end

      def setup?(settings)
        @endpoint = settings['CI_SERVICE_ENDPOINT']
        @username = settings['CI_SERVICE_USERNAME']
        @password = settings['CI_SERVICE_PASSWORD']

        true
      end

      def is_branch_green?(app, branch, hash)
        true
      end
    end
  end
end
