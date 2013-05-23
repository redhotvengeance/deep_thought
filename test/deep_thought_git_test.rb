require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtGitTest < MiniTest::Unit::TestCase
  def setup
    DatabaseCleaner.start

    if File.directory?(".projects/_test")
      FileUtils.rm_rf(".projects/_test")
    end

    @project = DeepThought::Project.new(:name => '_test', :repo_url => './test/fixtures/git-test', :deploy_type => 'capy')
  end

  def teardown
    if File.directory?(".projects/_test")
      FileUtils.rm_rf(".projects/_test")
    end

    DatabaseCleaner.clean
  end

  def test_git_setup_failed
    @project.repo_url = 'http://fake.url'
    assert !DeepThought::Git.setup(@project)
  end

  def test_git_setup_success
    @project.repo_url = './test/fixtures/git-test'
    assert DeepThought::Git.setup(@project)
  end

  def test_git_get_latest_commit_for_branch_success
    assert_kind_of Array, DeepThought::Git.get_latest_commit_for_branch(@project, 'master')
  end

  def test_git_get_latest_commit_for_branch_failed
    assert_empty DeepThought::Git.get_latest_commit_for_branch(@project, 'no-branch')
  end

  def test_git_switch_to_branch_success
    assert DeepThought::Git.switch_to_branch(@project, 'master')
  end

  def test_git_switch_to_branch_failed
    assert_raises(DeepThought::Git::GitBranchNotFoundError) { DeepThought::Git.switch_to_branch(@project, 'no-branch') }
  end

  def test_git_get_list_of_branches
    assert_equal(DeepThought::Git.get_list_of_branches(@project), ['master', 'topic'])
  end
end
