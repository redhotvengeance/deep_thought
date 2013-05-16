require "sinatra"
require 'rack/ssl'
require "deep_thought/git"
require "deep_thought/deployer"

module DeepThought
  class Api < Sinatra::Base
    if ENV['RACK_ENV'] != 'development' && ENV['RACK_ENV'] != 'test'
      use Rack::SSL
    end

    before '*' do
      if request.env['HTTP_AUTHORIZATION'] =~ /Token token="[a-zA-Z0-9\+=]+"/
        token = request.env['HTTP_AUTHORIZATION'].gsub(/Token token="/, '').gsub(/"/, '')

        @user = DeepThought::User.find_by_api_key("#{token}")

        if !@user
          halt 401
        end
      else
        halt 401
      end
    end

    get '/status' do
      if DeepThought::Deployer.is_deploying?
        [500, "I'm currently in mid-deployment."]
      else
        [200, "I'm ready to ponder the infinitely complex questions of the universe."]
      end
    end

    get '*' do
      [401, "I don't got what you're trying to GET."]
    end

    post '/' do
      [500, "Must supply app name."]
    end

    post '/:app' do
      app = params[:app]
      branch = params[:branch] || 'master'
      actions = params[:actions].split(',') if params[:actions]
      environment = params[:environment] if params[:environment]
      box = params[:box] if params[:box]
      on_behalf_of = params[:on_behalf_of] if params[:on_behalf_of]
      variables = nil

      params.each do |k, v|
        key = k.to_s
        if key != 'app' && key != 'branch' && key != 'actions' && key != 'environment' && key != 'box' && key != 'on_behalf_of' && key != 'splat' && key != 'captures'
          variables ||= Hash.new
          variables[k] = v
        end
      end

      if DeepThought::Deployer.is_deploying?
        return [500, "Sorry, but I'm currently in mid-deployment. Ask me again when I'm done."]
      end

      project = Project.find_by_name(app)

      if !project
        return [500, "Hmm, that project doesn't appear to exist. Have you set it up?"]
      end

      hashes = Git.get_latest_commit_for_branch(project, branch)

      if !hashes
        return [500, "Woah - I can't seem to access that repo. Are you sure the URL is correct and that I have access to it?"]
      end

      hash = hashes[0]

      if !hash
        return [500, "Hmm, that branch doesn't appear to exist. Have you pushed it?"]
      end

      if DeepThought::CIService.ci_service
        DeepThought::CIService.is_branch_green?(app, branch, hash)
      end

      deploy = DeepThought::Deploy.new
      deploy.project_id = project.id
      deploy.user_id = @user.id
      deploy.branch = branch

      response = "executing deploy"

      if actions
        deploy.actions = actions.to_yaml

        actions.each do |action|
          response += "/#{action}"
        end
      end

      deploy.commit = hash.to_s

      response += " #{app}/#{branch}/#{hash}"

      if environment
        deploy.environment = environment
        response += " to #{environment}"

        if box
          deploy.box = box
          response += "/#{box}"
        end
      end

      if variables
        deploy.variables = variables.to_yaml
        response += " with #{variables.to_s}"
      end

      if on_behalf_of
        deploy.on_behalf_of = on_behalf_of
        response += " on behalf of #{on_behalf_of}"
      end

      deploy.via = 'api'
      deploy.save!

      response
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
