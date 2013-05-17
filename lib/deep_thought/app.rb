require 'sinatra'
require 'sinatra/json'
require 'rack/ssl'
require 'rack/csrf'
require 'haml'

module DeepThought
  class App < Sinatra::Base
    helpers Sinatra::JSON

    set :root, File.dirname(__FILE__)
    set :public_folder, File.join(root, 'public')
    set :views, File.join(root, 'views')
    set :haml, :layout => :"layouts/layout"

    if ENV['RACK_ENV'] != 'development' && ENV['RACK_ENV'] != 'test'
      use Rack::SSL
    end

    use Rack::Session::Cookie, :secret => ENV['SESSION_SECRET']
    use Rack::Csrf, :raise => true
    use Rack::MethodOverride

    set :deep_thought_message, "Hello, human."

    before /^(?!\/(login|logout))/ do
      if !session[:user_id]
        redirect '/login'
      end
    end

    get '/' do
      projects = DeepThought::Project.all

      if projects.count > 0
        settings.deep_thought_message = "Deep Thought has the answer."
      else
        settings.deep_thought_message = "Deep Thought knows of no projects."
      end

      haml :"projects/index", :locals => {:projects => projects}
    end

    get '/login' do
      if session[:user_id]
        redirect '/'
      end

      haml :"sessions/login"
    end

    post '/login' do
      user = User.authenticate(params[:email], params[:password])

      if user
        session[:user_id] = user.id
        redirect '/'
      else
        redirect '/login'
      end
    end

    delete '/logout' do
      session[:user_id] = nil
      redirect '/login'
    end

    get '/projects/add/new' do
      project = DeepThought::Project.new

      haml :"projects/new", :locals => {:project => project}
    end

    get '/project/add/new' do
      redirect "/projects/add/new"
    end

    post '/projects/add/new' do
      project = DeepThought::Project.new(params[:project])

      if project.save
        redirect '/'
      else
        settings.deep_thought_message = "Deep Thought has a problem with your request."
        haml :"projects/new", :locals => {:project => project}
      end
    end

    get '/projects/edit/:name' do
      project = DeepThought::Project.find_by_name(params[:name])

      haml :"projects/edit", :locals => {:project => project}
    end

    get '/project/edit/:name' do
      redirect "/projects/edit/#{params[:name]}"
    end

    put '/projects/edit/:name' do
      project = DeepThought::Project.find_by_name(params[:name])

      if project.update_attributes(params[:project])
        redirect "/projects/#{project.name}"
      else
        settings.deep_thought_message = "Deep Thought has a problem with your request."
        haml :"projects/edit", :locals => {:project => project}
      end
    end

    delete '/projects/delete/:name' do
      project = DeepThought::Project.find_by_name(params[:name])

      project.destroy

      redirect '/'
    end

    get '/projects/:name' do
      project = DeepThought::Project.find_by_name(params[:name])
      branches = DeepThought::Git.get_list_of_branches(project) || []

      if branches.include?('master')
        branches.unshift(branches.slice!(branches.index('master')))
      end

      deploy = DeepThought::Deploy.new

      settings.deep_thought_message = "Now pondering: #{project.name}."

      haml :"projects/show", :locals => {:project => project, :branches => branches, :deploy => deploy}
    end

    get '/project/:name' do
      redirect "/projects/#{params[:name]}"
    end

    get '/projects/:name/deploys' do
      project = DeepThought::Project.find_by_name(params[:name])
      deploys = project.deploys.order('created_at DESC')

      settings.deep_thought_message = "Now remembering: #{project.name}."

      haml :"history/index", :locals => {:project => project, :deploys => deploys}
    end

    get '/project/:name/deploys' do
      redirect "/projects/#{params[:name]}/deploys"
    end

    get '/projects/:name/deploys/:id' do
      project = DeepThought::Project.find_by_name(params[:name])
      deploy = project.deploys.find(params[:id])

      settings.deep_thought_message = "Now remembering #{project.name} deploy: #{deploy.id}."

      haml :"history/show", :locals => {:project => project, :deploy => deploy}
    end

    get '/projects/:name/deploy/:id' do
      redirect "/projects/#{params[:name]}/deploys/#{params[:id]}"
    end

    get '/project/:name/deploys/:id' do
      redirect "/projects/#{params[:name]}/deploys/#{params[:id]}"
    end

    get '/project/:name/deploy/:id' do
      redirect "/projects/#{params[:name]}/deploys/#{params[:id]}"
    end

    post '/projects/:name/deploy' do
      project = DeepThought::Project.find_by_name(params[:name])
      branches = DeepThought::Git.get_list_of_branches(project)

      if branches.include?('master')
        branches.unshift(branches.slice!(branches.index('master')))
      end

      deploy = DeepThought::Deploy.new

      deploy.branch = params[:deploy][:branch]
      deploy.commit = DeepThought::Git.get_latest_commit_for_branch(project, deploy.branch)[0].to_s
      deploy.environment = params[:deploy][:environment] if !params[:deploy][:environment].blank?
      deploy.box = params[:deploy][:box] if !params[:deploy][:box].blank?

      if params[:deploy][:actions]
        actions = params[:deploy][:actions]
        actions.reject!(&:empty?).blank?

        if actions.count > 0
          deploy.actions = actions.to_yaml
        end
      end

      if params[:deploy][:variables]
        vars = params[:deploy][:variables]
        keys = vars[:keys]
        values = vars[:values]

        variables = Hash[keys.zip(values)]
        variables.reject! { |k, v| k == '' }
        variables.reject! { |k, v| v == '' }

        if variables.count > 0
          deploy.variables = variables.to_yaml
        end
      end

      deploy.project_id = project.id
      deploy.user_id = current_user.id
      deploy.via = 'web'

      if !deploy.save
        settings.deep_thought_message = "Deep Thought has a problem with your request."
        haml :"projects/show", :locals => {:project => project, :branches => branches, :deploy => deploy}
      end

      redirect "/projects/#{params[:name]}"
    end

    get '/users' do
      users = DeepThought::User.all

      settings.deep_thought_message = "Deep Thought loves you."

      haml :"users/index", :locals => {:users => users}
    end

    get '/users/new' do
      user = DeepThought::User.new

      haml :"users/new", :locals => {:user => user}
    end

    post '/users/new' do
      user = DeepThought::User.new(params[:user])

      if user.save
        redirect '/users'
      else
        settings.deep_thought_message = "Deep Thought has a problem with your request."
        haml :"users/new", :locals => {:user => user}
      end
    end

    get '/users/:id' do
      user = User.find(params[:id])

      settings.deep_thought_message = "Deep Thought loves you."

      haml :"users/show", :locals => {:user => user}
    end

    put '/users/:id' do
      user = DeepThought::User.find(params[:id])

      if user.update_attributes(params[:user])
        redirect '/users'
      else
        settings.deep_thought_message = "Deep Thought has a problem with your request."
        haml :"users/show", :locals => {:user => user}
      end
    end

    delete '/users/:id' do
      user = DeepThought::User.find(params[:id])

      user.destroy

      redirect '/users'
    end

    post '/users/:id/key' do
      user = DeepThought::User.find(params[:id])

      user.generate_api_key

      redirect "/users/#{params[:id]}"
    end

    get '/deploying' do
      pass unless is_json?

      json :deploying => DeepThought::Deployer.is_deploying?
    end

    get '*' do
      redirect '/'
    end

    helpers do
      def csrf_tag
        Rack::Csrf.csrf_tag(env)
      end

      def current_user
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
      end

      def current_route(item)
        path = request.path_info

        case item
        when 'projects'
          if path == '/' or path =~ %r{/projects}
            "current"
          end
        when 'users'
          unless path == "/users/#{@current_user.id}"
            if path =~ %r{/users}
              "current"
            end
          end
        when 'me'
          if path == "/users/#{@current_user.id}"
            "current"
          end
        end
      end

      def is_json?
        is_json = false

        request.accept.each do |a|
          is_json = true if a.to_s == 'application/json'
        end

        is_json
      end

      def is_deploying?
        if DeepThought::Deployer.is_deploying?
          settings.deep_thought_message = "Deep Thought is deploying..."
          true
        else
          false
        end
      end
    end
  end
end
