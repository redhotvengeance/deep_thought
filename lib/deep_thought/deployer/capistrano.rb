module DeepThought
  module Deployer
    class Capistrano
      def execute(project, params)
        cap_command = "cap "

        cap_command += "#{params['env']} " if params['env']

        cap_command += "deploy"

        if params['actions']
          params['actions'].each do |action|
            cap_command += ":#{action}"
          end
        end

        cap_command += " -s branch=#{params['branch']}" if params['branch']
        cap_command += " -s box=#{params['box']}" if params['box']

        commands = []

        commands << "cd ./.projects/#{project.name}"
        commands << "#{cap_command} > /dev/null 2>&1"

        system "#{commands.join(" && ")}"
      end
    end
  end
end
