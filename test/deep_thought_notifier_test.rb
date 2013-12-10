require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtNotifierTest < MiniTest::Unit::TestCase
  def setup
    DatabaseCleaner.start

    DeepThought::Deployer.adapters = {}

    @deployer = mock('class')
    @deployer.expects(:new).returns(@deployer)
    @deployer.expects(:setup?).returns(true)

    @project = DeepThought::Project.create(:name => '_test', :repo_url => './test/fixtures/project-test')
    @user = DeepThought::User.create(:email => 'test@test.com', :password => 'secret', :password_confirmation => 'secret', :api_key => '12345', :notification_url => 'url')
    @deploy = DeepThought::Deploy.new(:project_id => @project.id, :user_id => @user.id, :branch => 'mock', :commit => '12345')
  end

  def teardown
    DatabaseCleaner.clean
  end

  def test_api_notifier_success
    DeepThought::Notifier.expects(:notify).with(@user, 'SUCCESS: _test mock')
    @deployer.expects(:execute?).with(@deploy, {'deploy_type' => 'mock'}).returns(true)
    DeepThought::Deployer.register_adapter('mock', @deployer)
    assert @deploy.save
  end

  def test_api_notifier_failed
    DeepThought::Notifier.expects(:notify).with(@user, 'FAILED: _test mock')
    @deployer.expects(:execute?).with(@deploy, {'deploy_type' => 'mock'}).returns(false)
    DeepThought::Deployer.register_adapter('mock', @deployer)
    assert_raises(DeepThought::Deployer::DeploymentFailedError) { @deploy.save }
  end
end
