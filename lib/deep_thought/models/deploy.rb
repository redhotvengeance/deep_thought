module DeepThought
  class Deploy < ActiveRecord::Base
    belongs_to :project
    belongs_to :user

    after_create :queue

    validates_presence_of :branch
    validates_presence_of :commit
    validates_presence_of :project
    validates_presence_of :user

    def queue
      Delayed::Job.enqueue self
    end

    def perform
      DeepThought::Deployer.execute(self)
    end
  end
end
