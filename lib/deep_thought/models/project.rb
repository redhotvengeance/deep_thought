require 'fileutils'

module DeepThought
  class Project < ActiveRecord::Base
    has_many :deploys

    before_destroy :delete_repo

    validates :name, presence: true, uniqueness: true
    validates :repo_url, presence: true
    validates :deploy_type, presence: true

    private

    def delete_repo
      if File.directory?(".projects/#{self.name}")
        FileUtils.rm_rf(".projects/#{self.name}")
      end
    end
  end
end
