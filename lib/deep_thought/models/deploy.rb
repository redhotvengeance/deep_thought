module DeepThought
  class Deploy < ActiveRecord::Base
    belongs_to :project
    belongs_to :user

    validates_presence_of :branch
    validates_presence_of :commit
    validates_presence_of :project
    validates_presence_of :user
  end
end
