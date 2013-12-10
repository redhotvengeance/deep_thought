require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtProjectTest < MiniTest::Unit::TestCase
  def setup
    DatabaseCleaner.start

    if File.directory?(".projects/_test")
      FileUtils.rm_rf(".projects/_test")
    end

    deployer = mock('class')
    deployer.stubs(:new).returns(deployer)
    deployer.stubs(:setup?)
    DeepThought::Deployer.register_adapter('mock', deployer)

    @project = DeepThought::Project.create(:name => '_test', :repo_url => './test/fixtures/project-test')
  end

  def teardown
    if File.directory?(".projects/_test")
      FileUtils.rm_rf(".projects/_test")
    end

    DatabaseCleaner.clean
  end

  def test_project_destroy_deletes_repo
    FileUtils.mkdir_p(".projects/#{@project.name}")

    @project.destroy

    assert !File.directory?(".projects/#{@project.name}")
  end
end
