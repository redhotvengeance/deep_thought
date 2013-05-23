require 'grit'

module DeepThought
  module Git
    class GitRepositoryNotFoundError < StandardError; end
    class GitBranchNotFoundError < StandardError; end

    def self.setup(project)
      exit_status = system "git clone #{project.repo_url} .projects/#{project.name} > /dev/null 2>&1"

      if exit_status
        if !File.directory?(".projects/#{project.name}/.git")
          false
        else
          if Dir.entries(".projects/#{project.name}") == [".", "..", ".git"]
            false
          else
            true
          end
        end
      else
        false
      end
    end

    def self.get_list_of_branches(project)
      return nil if !self.clone_if_not_exists(project)

      system "cd ./.projects/#{project.name} && git fetch -p > /dev/null 2>&1"

      repo = Grit::Repo.new(".projects/#{project.name}")

      branches = Array.new

      repo.remotes.each do |remote|
        branch = remote.name.gsub(/origin\//, '')
        branches.push(branch) if branch != 'HEAD'
      end

      branches
    end

    def self.get_latest_commit_for_branch(project, branch)
      return nil if !self.clone_if_not_exists(project)

      system "cd ./.projects/#{project.name} && git fetch -p > /dev/null 2>&1"

      repo = Grit::Repo.new(".projects/#{project.name}")
      repo.commits("origin/#{branch}", 1)
    end

    def self.switch_to_branch(project, branch)
      return nil if !self.clone_if_not_exists(project)

      exit_status = system "cd ./.projects/#{project.name} && git fetch -p > /dev/null 2>&1 && git reset --hard origin/#{branch} > /dev/null 2>&1"

      if exit_status
        true
      else
        raise GitBranchNotFoundError, "#{project.name} doesn't appear to have a branch called #{branch}. Have you pushed it?"
      end
    end

    private

    def self.clone_if_not_exists(project)
      if !File.directory?(".projects/#{project.name}/.git")
        if !self.setup(project)
          return false
        end
      end

      true
    end
  end
end
