require "deep_thought/git"

module DeepThought
  module Deployer
    class DeployerNotFoundError < StandardError; end
    class DeploymentFailedError < StandardError; end

    def self.adapters
      @adapters ||= {}
    end

    def self.register_adapter(name, service)
      self.adapters[name] = service
    end

    def self.execute(project, params)
      Git.switch_to_branch(project, params['branch'])

      if @adapters.keys.include?(project['deploy_type'])
        klass = adapters[project['deploy_type']]
        deployer = klass.new
        deploy_status = deployer.execute(project, params)

        if deploy_status
          true
        else
          raise DeploymentFailedError, "The deployment pondered it's own short existence before hitting the ground with a sudden wet thud."
        end
      else
        raise DeployerNotFoundError, "I don't have a deployer called \"#{project['deploy_type']}\"."
      end
    end
  end
end
