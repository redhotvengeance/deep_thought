require 'grit'

module DeepThought
  class Git
    def self.setup(app)
      # TODO: Add project/git setup
    end

    def self.get_latest_commit_for_branch(app, branch)
      repo = Grit::Repo.new("./.projects/#{app}")
      repo.commits("origin/#{branch}", 1)
    end
  end
end
