$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'deep_thought'
require 'rubygems'
require 'fileutils'
gem 'minitest'
require 'minitest/autorun'
require 'rack/test'
require 'mocha/setup'
require 'database_cleaner'

begin; require 'turn/autorun'; rescue LoadError; end

ENV['RACK_ENV'] = 'test'

DeepThought.setup(ENV)

DatabaseCleaner.clean_with(:truncation)
DatabaseCleaner.strategy = :transaction

MiniTest::Unit::TestCase.add_setup_hook {
  DatabaseCleaner.start

  if File.directory?(".projects/_test")
    FileUtils.rm_rf(".projects/_test")
  end
}

MiniTest::Unit::TestCase.add_teardown_hook {
  if File.directory?(".projects/_test")
    FileUtils.rm_rf(".projects/_test")
  end

  DatabaseCleaner.clean
}
