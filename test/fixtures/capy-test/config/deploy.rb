set :stages, %w(development staging production)
set :default_stage, "development"
require 'capistrano/ext/multistage'

set :branch, "master"

namespace :deploy do
  task :default do
    puts "branch: #{branch}"
    puts "environment: #{env}"
    puts "box: #{box}" if fetch(:box, nil)

    update
    configure
    restart
    cleanup
  end

  task :fail_test, :except => { :no_release => true } do
    # error
    updat
  end

  task :update do
    transaction do
      update_code
      create_release
      symlink
    end
  end

  task :update_code, :except => { :no_release => true } do
    puts 'updating code...'
  end

  task :create_release, :except => { :no_release => true } do
    puts 'creating release...'
  end

  task :symlink, :except => { :no_release => true } do
    puts 'symlinking...'
  end

  task :configure, :except => { :no_release => true } do
    puts 'configuring up...'
  end

  task :restart, :except => { :no_release => true } do
    puts 'restarting...'
  end

  task :cleanup, :except => { :no_release => true } do
    puts 'cleaning up...'
  end
end
