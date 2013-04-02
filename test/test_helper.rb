$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

ENV['RACK_ENV'] = 'test'

require 'deep_thought'
require 'rubygems'
gem 'minitest'
require 'minitest/autorun'
require 'rack/test'
