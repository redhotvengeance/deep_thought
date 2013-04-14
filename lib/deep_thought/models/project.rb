module DeepThought
  class Project < ActiveRecord::Base
    validates :name, presence: true, uniqueness: true
    validates :repo_url, presence: true
    validates :deploy_type, presence: true
  end
end
