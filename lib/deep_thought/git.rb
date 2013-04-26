require 'grit'

module DeepThought
  class Git
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

    def self.get_latest_commit_for_branch(project, branch)
      if !File.directory?(".projects/#{project.name}/.git")
        if !self.setup(project)
          return nil
        end
      end

      system "cd ./.projects/#{project.name} && git fetch --all > /dev/null 2>&1"

      repo = Grit::Repo.new(".projects/#{project.name}")
      repo.commits("origin/#{branch}", 1)
    end
  end
end
