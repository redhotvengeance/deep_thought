module DeepThought
  module Deployer
    class Capistrano
      def execute(deploy)
        cap_command = "cap "

        cap_command += "#{deploy.environment} " if deploy.environment

        cap_command += "deploy"

        if deploy.actions
          actions = YAML.load(deploy.actions)
          actions.each do |action|
            cap_command += ":#{action}"
          end
        end

        cap_command += " -s branch=#{deploy.branch}"
        cap_command += " -s box=#{deploy.box}" if deploy.box

        if deploy.variables
          variables = YAML.load(deploy.variables)
          variables.each do |k, v|
            cap_command += " -s #{k}=#{v}"
          end
        end

        commands = []

        commands << "cd ./.projects/#{deploy.project.name}"
        commands << "#{cap_command} 2>&1"

        command = commands.join(" && ")

        log = `#{command}`

        deploy.log = log

        $?.success?
      end
    end
  end
end
