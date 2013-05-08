require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtCapistranoTest < MiniTest::Unit::TestCase
  def setup
    DatabaseCleaner.start

    @project = DeepThought::Project.new(:name => '_capy-test', :deploy_type => 'capistrano')
    @deployer = DeepThought::Deployer::Capistrano.new

    FileUtils.cp_r "./test/fixtures/capy-test", "./.projects/_capy-test"
  end

  def teardown
    FileUtils.rm_rf "./.projects/_capy-test"

    DatabaseCleaner.clean
  end

  def test_deployer_execute_success
    assert @deployer.execute(@project, {"branch" => "master"})
  end

  def test_deployer_execute_failed
    assert !@deployer.execute(@project, {"branch" => "master", "actions" => ["fail_test"]})
  end
end
