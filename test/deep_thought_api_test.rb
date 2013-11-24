require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtApiTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def setup
    DatabaseCleaner.start

    if File.directory?(".projects/_test")
      FileUtils.rm_rf(".projects/_test")
    end

    @user = DeepThought::User.create(:email => 'test@test.com', :password => 'secret', :password_confirmation => 'secret', :api_key => '12345')
  end

  def teardown
    if File.directory?(".projects/_test")
      FileUtils.rm_rf(".projects/_test")
    end

    DatabaseCleaner.clean
  end

  def app
    DeepThought.app
  end

  def test_api_unauthorized
    header 'Accept', 'application/json'
    get '/deploy/'
    assert !last_response.ok?
    assert_equal 401, last_response.status
  end

  def test_api_get
    header 'Accept', 'application/json'
    get '/deploy/', {}, {"HTTP_AUTHORIZATION" => 'Token token="12345"'}
    assert !last_response.ok?
    assert_equal "I don't got what you're trying to GET.", last_response.body
  end

  def test_api_post_empty
    header 'Accept', 'application/json'
    post '/deploy/', {}, {"HTTP_AUTHORIZATION" => 'Token token="12345"'}
    assert !last_response.ok?
    assert_equal "Must supply app name.", last_response.body
  end

  def test_api_setup_success
    header 'Accept', 'application/json'
    post '/deploy/setup/test', {:repo_url => 'http://fake.url', :deploy_type => 'capy'}.to_json, {"HTTP_AUTHORIZATION" => 'Token token="12345"'}
    assert last_response.ok?
  end

  def test_api_setup_failed
    header 'Accept', 'application/json'
    post '/deploy/setup/test', {}, {"HTTP_AUTHORIZATION" => 'Token token="12345"'}
    assert !last_response.ok?
    assert_equal "Sorry, but I need a project name, repo url, and deploy type. No exceptions, despite how nicely you ask.", last_response.body
  end

  def test_api_non_project
    header 'Accept', 'application/json'
    post '/deploy/test', {}, {"HTTP_AUTHORIZATION" => 'Token token="12345"'}
    assert !last_response.ok?
    assert_equal "Hmm, that project doesn't appear to exist. Have you set it up?", last_response.body
  end

  def test_api_no_repo
    project = DeepThought::Project.create(:name => '_test', :repo_url => 'http://fake.url', :deploy_type => 'capy')
    header 'Accept', 'application/json'
    post '/deploy/_test', {}, {"HTTP_AUTHORIZATION" => 'Token token="12345"'}
    assert !last_response.ok?
    assert_equal "I can't seem to access that repo. Are you sure the URL is correct and that I have access to it?", last_response.body
  end

  def test_api_no_branch
    project = DeepThought::Project.create(:name => '_test', :repo_url => './test/fixtures/git-test', :deploy_type => 'capy')
    branch = 'no-branch'
    header 'Accept', 'application/json'
    post '/deploy/_test', {:branch => branch}.to_json, {"HTTP_AUTHORIZATION" => 'Token token="12345"'}
    assert !last_response.ok?
    assert_equal "#{project.name} doesn't appear to have a branch called #{branch}. Have you pushed it?", last_response.body
  end

  def test_api_in_deployment
    DeepThought::Deployer.lock_deployer
    project = DeepThought::Project.create(:name => '_test', :repo_url => 'http://fake.url', :deploy_type => 'capy')
    header 'Accept', 'application/json'
    post '/deploy/_test', {}, {"HTTP_AUTHORIZATION" => 'Token token="12345"'}
    assert !last_response.ok?
    assert_equal "Sorry, but I'm currently in mid-deployment. Ask me again when I'm done.", last_response.body
  end

  def test_api_status_ready
    header 'Accept', 'application/json'
    get '/deploy/status', {}, {"HTTP_AUTHORIZATION" => 'Token token="12345"'}
    assert last_response.ok?
    assert_equal "I'm ready to ponder the infinitely complex questions of the universe.", last_response.body
  end

  def test_api_status_busy
    DeepThought::Deployer.lock_deployer
    header 'Accept', 'application/json'
    get '/deploy/status', {}, {"HTTP_AUTHORIZATION" => 'Token token="12345"'}
    assert !last_response.ok?
    assert_equal "I'm currently in mid-deployment.", last_response.body
  end
end
