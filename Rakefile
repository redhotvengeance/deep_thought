require "bundler/gem_tasks"
require 'dotenv/tasks'
require "./lib/deep_thought"

task :environment => :dotenv do
  DeepThought.setup(ENV)
end

