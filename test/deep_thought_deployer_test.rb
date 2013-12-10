require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtDeployerTest < MiniTest::Unit::TestCase
  def setup
    DatabaseCleaner.start

    DeepThought::Deployer.adapters = {}

    @deployer = mock('class')
    @deployer.stubs(:new).returns(@deployer)
    @deployer.stubs(:setup?).returns(true)
    DeepThought::Deployer.register_adapter('mock', @deployer)

    @project = DeepThought::Project.create(:name => '_test', :repo_url => './test/fixtures/project-test')
    @user = DeepThought::User.create(:email => 'test@test.com', :password => 'secret', :password_confirmation => 'secret')
    @deploy = DeepThought::Deploy.new(:project_id => @project.id, :user_id => @user.id, :branch => 'master', :commit => '12345')
  end

  def teardown
    DatabaseCleaner.clean
  end

  def test_config_not_found
    @deploy.branch = 'no-config'
    assert_raises(DeepThought::ProjectConfigNotFoundError) { @deploy.save }
  end

  def test_deployer_not_found
    DeepThought::Deployer.adapters = {}
    @deploy.branch = 'mock'
    assert_raises(DeepThought::Deployer::DeployerNotFoundError) { @deploy.save }
  end

  def test_deployer_setup_failed
    @deployer.stubs(:setup?).returns(false)
    @deploy.branch = 'mock'
    assert_raises(DeepThought::Deployer::DeployerSetupFailedError) { @deploy.save }
  end

  def test_deployer_execute_success
    @deploy.branch = 'mock'

    DeepThought::Notifier.stubs(:notify)
    @deployer.expects(:execute?).with(@deploy, {'deploy_type' => 'mock'}).returns(true)

    assert !@deploy.started_at
    assert !@deploy.finished_at
    assert !@deploy.was_successful

    assert @deploy.save
    assert @deploy.started_at
    assert @deploy.finished_at
    assert @deploy.was_successful
  end

  def test_deployer_execute_failed
    @deploy.branch = 'mock'

    DeepThought::Notifier.stubs(:notify)
    @deployer.expects(:execute?).with(@deploy, {'deploy_type' => 'mock'}).returns(false)

    assert !@deploy.started_at
    assert !@deploy.finished_at
    assert !@deploy.was_successful

    assert_raises(DeepThought::Deployer::DeploymentFailedError) { @deploy.save }

    assert @deploy.started_at
    assert @deploy.finished_at
    assert !@deploy.was_successful
  end

  def test_deployer_lock
    DeepThought::Deployer.lock_deployer
    @deployer.stubs(:execute?).with(@deploy).returns(true)
    assert_raises(DeepThought::Deployer::DeploymentInProgressError) { @deploy.save }
  end
end
