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
  gem.homepage      = "https://github.com/redhotvengeance/deep_thought"

  gem.files         = `git ls-files`.split("\n") - %w[.gitignore]
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "rake", "~>10.1"
  gem.add_dependency "sinatra", "~>1.4"
  gem.add_dependency "sinatra-contrib", "~>1.4"
  gem.add_dependency "json", "~>1.8"
  gem.add_dependency "activerecord", "~>3.2"
  gem.add_dependency "pg", "~>0.17"
  gem.add_dependency "rugged", "~>0.19"
  gem.add_dependency "httparty", "~>0.12"
  gem.add_dependency "bcrypt-ruby", "~>3.1"
  gem.add_dependency "rack-ssl", "~>1.3"
  gem.add_dependency "rack_csrf", "~>2.4"
  gem.add_dependency "haml", "~>4.0"
  gem.add_dependency "delayed_job_active_record", "~>0.4"

  # # development
  gem.add_development_dependency "shotgun", "~>0.9"
  gem.add_development_dependency "thin", "~>1.6"
  gem.add_development_dependency "racksh", "~>1.0.0"

  # # testing
  gem.add_development_dependency "minitest", "~>4.7"
  gem.add_development_dependency "mocha", "~>0.14"
  gem.add_development_dependency "database_cleaner", "~>1.2"
  gem.add_development_dependency "turn", "~>0.9"
  gem.add_development_dependency "capybara", "~>2.2"
end
