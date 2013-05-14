require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtCapistranoTest < MiniTest::Unit::TestCase
  def setup
    DatabaseCleaner.start

    DeepThought::Deploy.any_instance.stubs(:queue)

    @project = DeepThought::Project.create(:name => '_capy-test', :repo_url => './test/fixtures/git-test', :deploy_type => 'capistrano')
    @user = DeepThought::User.create(:email => 'test@test.com', :password => 'secret', :password_confirmation => 'secret')
    @deploy = DeepThought::Deploy.create(:project_id => @project.id, :user_id => @user.id, :branch => 'master', :commit => '12345')
    @deployer = DeepThought::Deployer::Capistrano.new

    FileUtils.cp_r "./test/fixtures/capy-test", "./.projects/_capy-test"
  end

  def teardown
    FileUtils.rm_rf "./.projects/_capy-test"

    DatabaseCleaner.clean
  end

  def test_capistrano_execute_success
    assert @deployer.execute(@deploy)
    assert @deploy.log
  end

  def test_capistrano_execute_failed
    @deploy.actions = ['fail_test'].to_yaml
    assert !@deployer.execute(@deploy)
    assert @deploy.log
  end
end
