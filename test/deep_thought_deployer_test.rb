require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtDeployerTest < MiniTest::Unit::TestCase
  def setup
    DatabaseCleaner.start

    DeepThought::Deployer.adapters = {}
    @project = DeepThought::Project.new(:name => '_test', :repo_url => './test/fixtures/git-test', :deploy_type => 'mock')
  end

  def teardown
    DatabaseCleaner.clean
  end

  def test_deployer_not_found
    @project.deploy_type = 'no-deployer'
    assert_raises(DeepThought::Deployer::DeployerNotFoundError) { DeepThought::Deployer.execute(@project, {"branch" => "master"}) }
  end

  def test_deployer_execute_success
    deployer = mock('class')
    deployer.expects(:new).returns(deployer)
    deployer.expects(:execute).returns(true)
    DeepThought::Deployer.register_adapter('mock', deployer)
    assert DeepThought::Deployer.execute(@project, {"branch" => "master"})
  end

  def test_deployer_execute_failed
    deployer = mock('class')
    deployer.expects(:new).returns(deployer)
    deployer.expects(:execute).returns(false)
    DeepThought::Deployer.register_adapter('mock', deployer)
    assert_raises(DeepThought::Deployer::DeploymentFailedError) { DeepThought::Deployer.execute(@project, {"branch" => "master"}) }
  end

  def test_deployer_lock
    DeepThought::Deployer.lock_deployer
    assert_raises(DeepThought::Deployer::DeploymentInProgressError) { DeepThought::Deployer.execute(@project, {"branch" => "master"}) }
  end
end
