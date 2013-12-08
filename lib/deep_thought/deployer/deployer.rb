module DeepThought
  module Deployer
    class Deployer
      def initialize
        if self.class.name == 'DeepThought::Deployer::Deployer'
          raise "#{self.class.name} is abstract, you cannot instantiate it directly."
        end
      end

      def setup(project, config)
      end

      def execute(deploy, config)
      end
    end
  end
end
