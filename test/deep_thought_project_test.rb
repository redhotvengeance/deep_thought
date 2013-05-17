require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtProjectTest < MiniTest::Unit::TestCase
  def setup
    DatabaseCleaner.start

    if File.directory?(".projects/_test")
      FileUtils.rm_rf(".projects/_test")
    end

    @project = DeepThought::Project.create(:name => '_test', :repo_url => './test/fixtures/git-test', :deploy_type => 'capy')
  end

  def teardown
    if File.directory?(".projects/_test")
      FileUtils.rm_rf(".projects/_test")
    end

    DatabaseCleaner.clean
  end

  def test_project_destroy_deletes_repo
    DeepThought::Git.setup(@project)

    assert File.directory?(".projects/_test")

    @project.destroy

    assert !File.directory?(".projects/_test")
  end
end
