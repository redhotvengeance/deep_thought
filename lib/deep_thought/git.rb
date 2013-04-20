require 'grit'

module DeepThought
  class Git
    def self.setup(project)
      repo = Grit::Git.new(".projects/#{project.name}")

      process = repo.clone({:quiet => false, :verbose => true, :progress => true, :branch => 'master'}, project.repo_url, ".projects/#{project.name}")

      if !File.directory?(".projects/#{project.name}/.git")
        false
      else
        true
      end
    end

    def self.get_latest_commit_for_branch(project, branch)
      if !File.directory?(".projects/#{project.name}/.git")
        if !self.setup(project)
          return nil
        end
      end

      repo = Grit::Repo.new(".projects/#{project.name}")
      repo.git.fetch
      repo.commits("origin/#{branch}", 1)
    end
  end
end
