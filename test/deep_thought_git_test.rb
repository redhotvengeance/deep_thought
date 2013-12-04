require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtGitTest < MiniTest::Unit::TestCase
  def setup
    DatabaseCleaner.start

    if File.directory?(".projects/_test")
      FileUtils.rm_rf(".projects/_test")
    end

    deployer = mock('class')
    deployer.stubs(:new).returns(deployer)
    deployer.stubs(:setup)
    DeepThought::Deployer.register_adapter('mock', deployer)

    @project = DeepThought::Project.new(:name => '_test', :repo_url => './test/fixtures/project-test')
  end

  def teardown
    if File.directory?(".projects/_test")
      FileUtils.rm_rf(".projects/_test")
    end

    DatabaseCleaner.clean
  end

  def test_git_setup_failed
    @project.repo_url = 'http://fake.url'
    @project.save
    # assert !@project.id
    assert !DeepThought::Git.setup(@project)
  end

  def test_git_setup_success
    assert @project.save!
  end

  def test_git_get_latest_commit_for_branch_success
    @project.save!
    assert_kind_of String, DeepThought::Git.get_latest_commit_for_branch(@project, 'master')
  end

  def test_git_get_latest_commit_for_branch_failed
    @project.save!
    assert_raises(DeepThought::Git::GitBranchNotFoundError) { DeepThought::Git.switch_to_branch(@project, 'no-branch') }
  end

  def test_git_switch_to_branch_success
    @project.save!
    assert DeepThought::Git.switch_to_branch(@project, 'master')
  end

  def test_git_switch_to_branch_failed
    @project.save!
    assert_raises(DeepThought::Git::GitBranchNotFoundError) { DeepThought::Git.switch_to_branch(@project, 'no-branch') }
  end

  def test_git_get_list_of_branches
    @project.save!
    assert_equal ['master', 'mock', 'no-config'], DeepThought::Git.get_list_of_branches(@project)
  end
end
