require 'fileutils'

module DeepThought
  class ProjectConfigNotFoundError < StandardError; end

  class Project < ActiveRecord::Base
    has_many :deploys

    before_destroy :delete_repo

    validates :name, presence: true, uniqueness: true
    validates :repo_url, presence: true

    def setup
      if DeepThought::Git.setup(self)
        if !File.exists?(".projects/#{self.name}/.deepthought.yml")
          delete_repo

          raise DeepThought::ProjectConfigNotFoundError, "#{self.name} does not appear to have a .deepthought.yml config file. Add one and try again."
        end
      else
        raise DeepThought::Git::GitRepositoryNotFoundError, "I can't seem to access that repo. Are you sure the URL is correct and that I have access to it?"
      end
    end

    def delete_repo
      if File.directory?(".projects/#{self.name}")
        FileUtils.rm_rf(".projects/#{self.name}")
      end
    end
  end
end
