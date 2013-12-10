require 'yaml'
require 'deep_thought/git'

module DeepThought
  module Deployer
    class DeployerNotFoundError < StandardError; end
    class DeployerSetupFailedError < StandardError; end
    class DeploymentFailedError < StandardError; end
    class DeploymentInProgressError < StandardError; end

    class << self
      attr_accessor :adapters
    end

    def self.adapters
      @adapters ||= {}
    end

    def self.register_adapter(name, service)
      self.adapters[name] = service
    end

    def self.create(project, user, via, options = {})
      branch = options[:branch] || 'master'
      actions = options[:actions] if options[:actions]
      environment = options[:environment] if options[:environment]
      box = options[:box] if options[:box]
      variables = options[:variables] if options[:variables]
      on_behalf_of = options[:on_behalf_of] if options[:on_behalf_of]

      if is_deploying?
        raise DeploymentInProgressError, "Sorry, but I'm currently in mid-deployment. Ask me again when I'm done."
      end

      project.setup

      hash = Git.get_latest_commit_for_branch(project, branch)

      project_config = YAML.load_file(".projects/#{project.name}/.deepthought.yml")

      if project_config['ci']
        uses_ci = project_config['ci']['enabled'] || false
      else
        uses_ci = false
      end

      if DeepThought::CIService.ci_service
        if uses_ci
          ci_project_name = project_config['ci']['name'] || project.name
          if !DeepThought::CIService.is_branch_green?(ci_project_name, branch, hash)
            raise DeepThought::CIService::CIBuildNotGreenError, "Commit #{hash} on project #{app} (in branch #{branch}) is not green. Fix it before deploying."
          end
        end
      end

      deploy = DeepThought::Deploy.new
      deploy.project_id = project.id
      deploy.user_id = user.id
      deploy.branch = branch
      deploy.commit = hash.to_s
      deploy.via = via
      deploy.actions = actions.to_yaml if actions
      deploy.environment = environment if environment
      deploy.box = box if environment && box
      deploy.variables = variables.to_yaml if variables
      deploy.on_behalf_of = on_behalf_of if on_behalf_of
      deploy.save!
    end

    def self.execute(deploy)
      if !is_deploying?
        Git.switch_to_branch(deploy.project, deploy.branch)

        deploy.project.setup

        project_config = YAML.load_file(".projects/#{deploy.project.name}/.deepthought.yml") || {}
        deploy_type = project_config['deploy_type'] || 'shell'

        if @adapters.keys.include?(deploy_type)
          lock_deployer

          deploy.started_at = DateTime.now
          deploy.in_progress = true
          deploy.save!

          klass = adapters[deploy_type]
          deployer = klass.new

          if !deployer.setup?(deploy.project, project_config)
            raise DeployerSetupFailedError, "Deployer setup failed - check the deployer and project settings."
          end

          deploy_status = deployer.execute?(deploy, project_config)

          unlock_deployer

          deploy.finished_at = DateTime.now
          deploy.in_progress = false

          deploy_summary = deploy.project.name

          if deploy.actions
            actions = YAML.load(deploy.actions)
            actions.each do |action|
              deploy_summary += "/#{action}"
            end
          end

          deploy_summary += " #{deploy.branch}"

          if deploy.environment
            deploy_summary += " to #{deploy.environment}"

            if deploy.box
              deploy_summary += "/#{deploy.box}"
            end
          end

          if deploy.variables
            variables = YAML.load(deploy.variables)
            variables.each do |k, v|
              deploy_summary += " #{k}=#{v}"
            end
          end

          if deploy_status
            deploy.was_successful = true
            deploy.save!

            DeepThought::Notifier.notify(deploy.user, "SUCCESS: #{deploy_summary}")

            true
          else
            deploy.was_successful = false
            deploy.save!

            DeepThought::Notifier.notify(deploy.user, "FAILED: #{deploy_summary}")

            raise DeploymentFailedError, "The deployment pondered its own short existence before hitting the ground with a sudden wet thud."
          end
        else
          raise DeployerNotFoundError, "I don't have a deployer called \"#{deploy_type}\"."
        end
      else
        raise DeploymentInProgressError, "Sorry, but I'm currently in mid-deployment. Ask me again when I'm done."
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
