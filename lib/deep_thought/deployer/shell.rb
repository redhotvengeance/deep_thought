require 'deep_thought/deployer/deployer'

module DeepThought
  module Deployer
    class Shell < DeepThought::Deployer::Deployer
      def execute(deploy, config)
        environment = deploy.environment || "development"

        root = config['root'] || "script/deploy"

        command = "#{root} #{environment} deploy"

        if deploy.actions
          actions = YAML.load(deploy.actions)
          actions.each do |action|
            command += ":#{action}"
          end
        end

        command += " branch=#{deploy.branch}"
        command += " box=#{deploy.box}" if deploy.box

        if deploy.variables
          variables = YAML.load(deploy.variables)
          variables.each do |k, v|
            command += " #{k}=#{v}"
          end
        end

        commands = []

        commands << "cd ./.projects/#{deploy.project.name}"
        commands << "#{command} 2>&1"

        executable = commands.join(" && ")

        log = `#{executable}`

        deploy.log = log

        $?.success?
      end
    end
  end
end
