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

      hash = Git.get_latest_commit_for_branch(app, branch)[0]

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
  end
end
