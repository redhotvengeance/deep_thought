require "sinatra"
require "deep_thought/git"

module DeepThought
  class Deploy < Sinatra::Base
    get '*' do
      [401, "I don't got what you're trying to GET."]
    end

    post '/' do
      [500, "Must supply app name."]
    end

    post '/:app' do
      app = params[:app]
      branch = params[:branch] || 'master'
      action = params[:action]
      environment = params[:environment]
      server = params[:server]

      project = Project.find_by_name(app)

      if !project
        return [500, "Hmm, that project doesn't appear to exist. Have you set it up?"]
      end

      hash = Git.get_latest_commit_for_branch(project, branch)[0]

      if !hash
        return [500, "Hmm, that branch doesn't appear to exist. Have you pushed it?"]
      end

      command = "executing deploy"

      if action
        command += "/#{action}"
      end

      command += " #{app}"

      if branch
        command += "/#{branch}"
      end

      command += " #{hash}"

      if environment
        command += " to #{environment}"

        if server
          command += "/#{server}"
        end
      end

      command
    end

    post '/setup/:app' do
      app = params[:app]
      repo_url = params[:repo_url]
      deploy_type = params[:deploy_type]

      if !repo_url || !deploy_type
        return [500, "Sorry, but I need a project name, repo url, and deploy type. No exceptions, despite how nicely you ask."]
      end

      project = Project.new(:name => app, :repo_url => repo_url, :deploy_type => deploy_type)

      if project.save
        [200, "Set up new project called #{app} which deploys with #{deploy_type} and pulls from #{repo_url}."]
      else
        [422, "Shit, something went wrong: #{project.errors.messages}."]
      end
    end
  end
end
