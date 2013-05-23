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

      project = DeepThought::Project.find_by_name(app)

      if !project
        return [500, "Hmm, that project doesn't appear to exist. Have you set it up?"]
      end

      options = {}
      options[:branch] = branch

      response = "executing deploy"

      if actions
        options[:actions] = actions

        actions.each do |action|
          response += "/#{action}"
        end
      end

      response += " #{app}/#{branch}"

      if environment
        options[:environment] = environment
        response += " to #{environment}"

        if box
          options[:box] = box
          response += "/#{box}"
        end
      end

      if variables
        options[:variables] = variables
        response += " with #{variables.to_s}"
      end

      if on_behalf_of
        options[:on_behalf_of] = on_behalf_of
        response += " on behalf of #{on_behalf_of}"
      end

      begin
        DeepThought::Deployer.create(project, @user, 'api', options)

        response
      rescue => e
        if ENV['RACK_ENV'] != 'test'
          puts e.inspect
          puts e.backtrace
        end

        [500, e.message]
      end
    end

    post '/setup/:app' do
      app = params[:app]
      repo_url = params[:repo_url]
      deploy_type = params[:deploy_type]
      ci = params[:ci] || 'true'

      if !repo_url || !deploy_type
        return [500, "Sorry, but I need a project name, repo url, and deploy type. No exceptions, despite how nicely you ask."]
      end

      project = Project.new(:name => app, :repo_url => repo_url, :deploy_type => deploy_type, :ci => ci)

      if project.save
        [200, "Set up new project called #{app} which deploys with #{deploy_type} and pulls from #{repo_url} and #{if ci == 'true' then 'uses' else 'doesn\'t use' end} ci."]
      else
        [422, "Shit, something went wrong: #{project.errors.messages}."]
      end
    end
  end
end
