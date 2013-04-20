$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'deep_thought'
require 'rubygems'
require 'fileutils'
gem 'minitest'
require 'minitest/autorun'
require 'rack/test'
require 'mocha'
require 'database_cleaner'

begin; require 'turn/autorun'; rescue LoadError; end

ENV['RACK_ENV'] = 'test'

DeepThought.setup(ENV)
