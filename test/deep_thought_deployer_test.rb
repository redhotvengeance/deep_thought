require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtDeployerTest < MiniTest::Unit::TestCase
  def setup
    DatabaseCleaner.start

    DeepThought::Deployer.adapters = {}
    @project = DeepThought::Project.create(:name => '_test', :repo_url => './test/fixtures/git-test', :deploy_type => 'mock')
    @user = DeepThought::User.create(:email => 'test@test.com', :password => 'secret', :password_confirmation => 'secret')
    @deploy = DeepThought::Deploy.new(:project_id => @project.id, :user_id => @user.id, :branch => 'master', :commit => '12345')
  end

  def teardown
    DatabaseCleaner.clean
  end

  def test_deployer_not_found
    @project.deploy_type = 'no-deployer'
    assert_raises(DeepThought::Deployer::DeployerNotFoundError) { @deploy.save }
  end

  def test_deployer_execute_success
    assert !@deploy.started_at
    assert !@deploy.finished_at
    assert !@deploy.was_successful
    deployer = mock('class')
    deployer.expects(:new).returns(deployer)
    deployer.expects(:execute).with(@deploy).returns(true)
    DeepThought::Deployer.register_adapter('mock', deployer)
    DeepThought::Notifier.stubs(:notify)
    assert @deploy.save
    assert @deploy.started_at
    assert @deploy.finished_at
    assert_equal @deploy.was_successful, true
  end

  def test_deployer_execute_failed
    assert !@deploy.started_at
    assert !@deploy.finished_at
    assert !@deploy.was_successful
    deployer = mock('class')
    deployer.expects(:new).returns(deployer)
    deployer.expects(:execute).with(@deploy).returns(false)
    DeepThought::Deployer.register_adapter('mock', deployer)
    DeepThought::Notifier.stubs(:notify)
    assert_raises(DeepThought::Deployer::DeploymentFailedError) { @deploy.save }
    assert @deploy.started_at
    assert @deploy.finished_at
    assert_equal @deploy.was_successful, false
  end

  def test_deployer_lock
    DeepThought::Deployer.lock_deployer
    assert_raises(DeepThought::Deployer::DeploymentInProgressError) { @deploy.save }
  end
end
