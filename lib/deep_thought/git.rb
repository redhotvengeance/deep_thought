require 'rugged'

module DeepThought
  module Git
    class GitRepositoryNotFoundError < StandardError; end
    class GitBranchNotFoundError < StandardError; end

    def self.setup(project)
      if !File.directory?(".projects/#{project.name}/.git")
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
      else
        true
      end
    end

    def self.get_list_of_branches(project)
      self.clone_if_not_exists(project)

      system "cd ./.projects/#{project.name} && git fetch -p > /dev/null 2>&1"

      repo = Rugged::Repository.new(".projects/#{project.name}")

      branches = Rugged::Branch.each_name(repo, :remote).sort
      branches.map! { |x| x.sub!('origin/', '') }
      branches.delete('HEAD')

      branches
    end

    def self.get_latest_commit_for_branch(project, branch)
      self.clone_if_not_exists(project)

      system "cd ./.projects/#{project.name} && git fetch -p > /dev/null 2>&1"

      repo = Rugged::Repository.new(".projects/#{project.name}")

      switch_to_branch(project, branch)

      repo.head.target
    end

    def self.switch_to_branch(project, branch)
      self.clone_if_not_exists(project)

      exit_status = system "cd ./.projects/#{project.name} && git fetch -p > /dev/null 2>&1 && git reset --hard origin/#{branch} > /dev/null 2>&1"

      if exit_status
        true
      else
        raise GitBranchNotFoundError, "#{project.name} doesn't appear to have a branch called #{branch}. Have you pushed it?"
      end
    end

    private

    def self.clone_if_not_exists(project)
      if !self.setup(project)
        raise DeepThought::Git::GitRepositoryNotFoundError, "I can't seem to access that repo. Are you sure the URL is correct and that I have access to it?"
      end
    end
  end
end
