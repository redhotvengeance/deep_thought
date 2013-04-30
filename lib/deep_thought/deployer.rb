require "deep_thought/git"

module DeepThought
  module Deployer
    class DeployerNotFoundError < StandardError; end
    class DeploymentFailedError < StandardError; end
    class DeploymentInProgressError < StandardError; end

    def self.adapters
      @adapters ||= {}
    end

    def self.register_adapter(name, service)
      self.adapters[name] = service
    end

    def self.execute(project, params)
      if !is_deploying?
        Git.switch_to_branch(project, params['branch'])

        if @adapters.keys.include?(project['deploy_type'])
          lock_deployer

          klass = adapters[project['deploy_type']]
          deployer = klass.new
          deploy_status = deployer.execute(project, params)

          unlock_deployer

          if deploy_status
            true
          else
            raise DeploymentFailedError, "The deployment pondered its own short existence before hitting the ground with a sudden wet thud."
          end
        else
          raise DeployerNotFoundError, "I don't have a deployer called \"#{project['deploy_type']}\"."
        end
      else
        raise DeploymentInProgressError, "There is a deployment is progress - please wait until it is finished."
      end
    end

    def self.is_deploying?
      deployer_state = get_or_create_deployer_state

      if deployer_state.state == 'true'
        true
      else
        false
      end
    end

    def self.lock_deployer
      deployer_state = get_or_create_deployer_state

      deployer_state.state = 'true'
      deployer_state.save
    end

    def self.unlock_deployer
      deployer_state = get_or_create_deployer_state

      deployer_state.state = 'false'
      deployer_state.save
    end

    private

    def self.get_or_create_deployer_state
      deployer_state = DeepThought::State.find_by_name('deployer')

      if !deployer_state
        deployer_state = DeepThought::State.create(:name => 'deployer', :state => 'false')
      end

      deployer_state
    end
  end
end
