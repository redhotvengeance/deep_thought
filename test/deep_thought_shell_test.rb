require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtShellTest < MiniTest::Unit::TestCase
  def setup
    DatabaseCleaner.start

    DeepThought::Deploy.any_instance.stubs(:queue)

    deployer = mock('class')
    deployer.stubs(:new).returns(deployer)
    deployer.stubs(:setup?).returns(true)
    DeepThought::Deployer.register_adapter('mock', deployer)

    @project = DeepThought::Project.create(:name => '_test', :repo_url => './test/fixtures/project-test')
    @user = DeepThought::User.create(:email => 'test@test.com', :password => 'secret', :password_confirmation => 'secret')
    @deploy = DeepThought::Deploy.create(:project_id => @project.id, :user_id => @user.id, :branch => 'master', :commit => '12345')
    @deployer = DeepThought::Deployer::Shell.new
  end

  def teardown
    FileUtils.rm_rf "./.projects/_test"

    DatabaseCleaner.clean
  end

  def test_shell_execute_success
    @project.setup
    assert @deployer.execute?(@deploy, {})
    assert @deploy.log
  end

  def test_shell_execute_failed
    @project.setup
    @deploy.actions = ['fail_test'].to_yaml
    assert !@deployer.execute?(@deploy, {})
    assert @deploy.log
  end
end
