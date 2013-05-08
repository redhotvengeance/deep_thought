require 'sinatra'
require 'rack/ssl'
require 'rack/csrf'
require 'haml'

module DeepThought
  class App < Sinatra::Base
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

      settings.deep_thought_message = "Deep Thought has the answer."

      haml :"home/index", :locals => {:projects => projects}
    end

    get '/login' do
      if session[:user_id]
        redirect '/'
      end

      haml :"home/login"
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

    get '/projects/:name' do
      project = DeepThought::Project.find_by_name(params[:name])

      settings.deep_thought_message = "Now pondering: #{project.name}."

      haml :"projects/index", :locals => {:project => project}
    end

    get '/project/:name' do
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
    end
  end
end
