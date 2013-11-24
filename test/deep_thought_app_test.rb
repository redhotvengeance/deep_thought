require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtAppTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include Capybara::DSL

  def setup
    DatabaseCleaner.start

    @user_email = 'test@test.com'
    @user_password = 'secret'
    @user = DeepThought::User.create(:email => @user_email, :password => @user_password, :password_confirmation => @user_password)
  end

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver

    if File.directory?(".projects/_test")
      FileUtils.rm_rf(".projects/_test")
    end

    DatabaseCleaner.clean
  end

  def app
    DeepThought.app
  end

  def test_app_root_logged_out
    get '/'
    follow_redirect!
    assert last_response.ok?
    assert_equal "http://example.org/login", last_request.url
  end

  def test_app_root_logged_in
    login(@user_email, @user_password)

    assert_equal 200, page.status_code
    assert_equal "http://www.example.com/", page.current_url
  end

  def test_app_logout
    login(@user_email, @user_password)

    assert_equal 200, page.status_code
    assert_equal "http://www.example.com/", page.current_url

    logout

    visit '/'
    assert_equal 200, page.status_code
    assert_equal "http://www.example.com/login", page.current_url
  end

  def test_app_user_generate_api_key
    login(@user_email, @user_password)

    visit "/users/#{@user.id}"
    assert_equal "http://www.example.com/users/#{@user.id}", page.current_url
    assert page.has_content?('no api key (yet)')

    DeepThought::User.any_instance.expects(:generate_api_key)

    @user.api_key = '12345'
    @user.save!

    within(".user-api-key") do
      click_button 'generate new api key'
    end

    assert_equal "http://www.example.com/users/#{@user.id}", page.current_url
    assert page.has_content?('12345')

    logout

    login(@user_email, @user_password)

    assert_equal 200, page.status_code
    assert_equal "http://www.example.com/", page.current_url
  end

  def test_app_add_user
    login(@user_email, @user_password)

    visit "/users/new"
    within(".content > form") do
      fill_in 'email', :with => 'new@user.email'
      fill_in 'password', :with => 'secret'
      fill_in 'password_confirmation', :with => 'secret'
      click_button 'create user'
    end

    assert_equal "http://www.example.com/users", page.current_url
    assert page.has_content?('new@user.email')
  end

  def test_app_delete_user
    login(@user_email, @user_password)

    visit "/users/new"
    within(".content > form") do
      fill_in 'email', :with => 'new@user.email'
      fill_in 'password', :with => 'secret'
      fill_in 'password_confirmation', :with => 'secret'
      click_button 'create user'
    end

    assert page.has_content?('new@user.email')

    within(".list") do
      click_link 'new@user.email'
    end

    click_button 'delete user'

    assert_equal "http://www.example.com/users", page.current_url
    assert !page.has_content?('new@user.email')
  end

  def test_app_user_update_email
    login(@user_email, @user_password)

    within("nav") do
      click_link "me"
    end

    within(".user-info > form") do
      fill_in 'email', :with => 'new@user.email'
      click_button 'update'
    end

    assert page.has_content?('new@user.email')

    logout

    login('new@user.email', @user_password)

    assert_equal "http://www.example.com/", page.current_url
  end

  def test_app_project_branches
    project = DeepThought::Project.create(:name => '_test', :repo_url => './test/fixtures/git-test', :deploy_type => 'mock')

    login(@user_email, @user_password)

    within(".list") do
      click_link '_test'
    end

    assert page.has_select?('deploy[branch]', :options => ['master', 'topic'])
  end

  def test_app_project_deploy_no_attributes
    DeepThought::Notifier.stubs(:notify)

    project = DeepThought::Project.create(:name => '_test', :repo_url => './test/fixtures/git-test', :deploy_type => 'mock')

    assert_equal 0, DeepThought::Deploy.count

    deployer = mock('class')
    deployer.expects(:new).returns(deployer)
    deployer.expects(:execute).returns(true)
    DeepThought::Deployer.register_adapter('mock', deployer)

    login(@user_email, @user_password)

    within(".list") do
      click_link '_test'
    end

    within(".deploy > form") do
      click_button 'deploy'
    end

    assert_equal 1, DeepThought::Deploy.count

    deploy = DeepThought::Deploy.all[0]

    assert_equal 'master', deploy.branch
    assert_nil deploy.environment
    assert_nil deploy.box
    assert_nil deploy.actions
    assert_nil deploy.variables
    assert_equal 'web', deploy.via
  end

  def test_app_project_deploy_with_attributes
    DeepThought::Notifier.stubs(:notify)

    project = DeepThought::Project.create(:name => '_test', :repo_url => './test/fixtures/git-test', :deploy_type => 'mock')

    assert_equal 0, DeepThought::Deploy.count

    deployer = mock('class')
    deployer.expects(:new).returns(deployer)
    deployer.expects(:execute).returns(true)
    DeepThought::Deployer.register_adapter('mock', deployer)

    login(@user_email, @user_password)

    within(".list") do
      click_link '_test'
    end

    within(".deploy > form") do
      select('topic', :from => 'deploy[branch]')
      fill_in 'environment', :with => 'development'
      fill_in 'box', :with => 'dev1'
      # TODO: Test actions and variables (need to integrate JavaScript into testing)
      click_button 'deploy'
    end

    assert_equal 1, DeepThought::Deploy.count

    deploy = DeepThought::Deploy.all[0]

    assert_equal 'topic', deploy.branch
    assert_equal 'development', deploy.environment
    assert_equal 'dev1', deploy.box
    assert_nil deploy.actions
    assert_nil deploy.variables
    assert_equal 'web', deploy.via
  end

  def test_app_project_history
    DeepThought::Notifier.stubs(:notify)

    project = DeepThought::Project.create(:name => '_test', :repo_url => './test/fixtures/git-test', :deploy_type => 'mock')

    login(@user_email, @user_password)

    visit '/projects/_test'

    click_link 'history...'

    assert !page.has_content?("deploy master by #{@user_email}")

    deploy = DeepThought::Deploy.new(:project_id => project.id, :user_id => @user.id, :branch => 'master', :commit => '12345')

    deployer = mock('class')
    deployer.expects(:new).returns(deployer)
    deployer.expects(:execute).with(deploy).returns(true)
    DeepThought::Deployer.register_adapter('mock', deployer)

    deploy.save

    visit '/projects/_test/deploys'

    assert page.has_content?("deploy master by #{@user_email}")
  end

  def test_app_add_project
    login(@user_email, @user_password)

    visit "/projects/add/new"
    within(".content > form") do
      fill_in 'name', :with => 'test'
      fill_in 'repo', :with => 'repo'
      fill_in 'type', :with => 'type'
      click_button 'create project'
    end

    assert_equal "http://www.example.com/", page.current_url
    assert page.has_content?('test')

    visit "/projects/edit/test"

    assert_equal 'test', find_field('name').value
    assert_equal 'repo', find_field('repo').value
    assert_equal 'type', find_field('type').value
    assert page.has_select?('project[ci]', :selected => 'true')
  end

  def test_app_edit_project
    login(@user_email, @user_password)

    visit "/projects/add/new"
    within(".content > form") do
      fill_in 'name', :with => 'test'
      fill_in 'repo', :with => 'repo'
      fill_in 'type', :with => 'type'
      click_button 'create project'
    end

    assert page.has_content?('test')

    visit "/projects/edit/test"
    within(".content > form") do
      fill_in 'name', :with => '_test'
      fill_in 'repo', :with => './test/fixtures/git-test'
      fill_in 'type', :with => 'type'
      select('false', :from => 'project[ci]')
      click_button 'update project'
    end

    assert_equal "http://www.example.com/projects/_test", page.current_url
    assert page.has_content?('Now pondering: _test')

    visit "/projects/edit/_test"

    assert_equal '_test', find_field('name').value
    assert_equal './test/fixtures/git-test', find_field('repo').value
    assert_equal 'type', find_field('type').value
    assert page.has_select?('project[ci]', :selected => 'false')
  end

  def test_app_delete_project
    login(@user_email, @user_password)

    visit "/projects/add/new"
    within(".content > form") do
      fill_in 'name', :with => '_test'
      fill_in 'repo', :with => './test/fixtures/git-test'
      fill_in 'type', :with => 'type'
      click_button 'create project'
    end

    assert page.has_content?('_test')

    within(".list") do
      click_link '_test'
    end

    click_link 'edit...'

    click_button 'delete project'

    assert_equal "http://www.example.com/", page.current_url
    assert !page.has_content?('_test')
  end
end
