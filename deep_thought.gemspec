# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'deep_thought/version'

Gem::Specification.new do |gem|
  gem.name          = "deep_thought"
  gem.version       = DeepThought::VERSION
  gem.authors       = ["Ian Lollar"]
  gem.email         = ["rhv@redhotvengeance.com"]
  gem.description   = "Deploy smart, not hard."
  gem.summary       = "Deploy smart, not hard."
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "sinatra", "~>1.4"
  gem.add_dependency "activerecord", "~>3.2"
  gem.add_dependency "pg", "~>0.15"
  gem.add_dependency "grit", "~>2.5"
  gem.add_dependency "httparty", "~>0.11"
  gem.add_dependency "bcrypt-ruby", "~>3.0"
  gem.add_dependency "rack-ssl", "~>1.3"
  gem.add_dependency "rack_csrf", "~>2.4"
  gem.add_dependency "haml", "~>4.0"
  gem.add_dependency "delayed_job_active_record", "~>0.4"
  gem.add_dependency "hirefire", "~>0.1"

  # development
  gem.add_development_dependency "shotgun", "~>0.9"
  gem.add_development_dependency "thin", "~>1.5"
  gem.add_development_dependency "tux", "~>0.3"
  gem.add_development_dependency "dotenv", "~>0.6"
  gem.add_dependency "capistrano", "~>2.14"
  gem.add_dependency "railsless-deploy", "~>1.1"

  # testing
  gem.add_development_dependency "minitest", "~>4.7"
  gem.add_development_dependency "mocha", "~>0.13"
  gem.add_development_dependency "database_cleaner", "~>0.9"
  gem.add_development_dependency "turn", "~>0.9"
  gem.add_development_dependency "capybara", "~>2.1"
end
