$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "gitlab_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "gitlab-engine"
  s.version     = GitlabEngine::VERSION
  s.authors     = ["John Long"]
  s.email       = ["asceth@gmail.com"]
  s.homepage    = "http://github.com/asceth/gitlab-engine"
  s.summary     = "GitLab as a Rails 3 engine"
  s.description = "GitLab is a self hosted git collaboration tool, this gem turns it into an engine for embedding in other applications."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.6"
  s.add_dependency "grit", "2.5.0"
  s.add_dependency "stamp"
  s.add_dependency "kaminari"
  s.add_dependency "haml-rails"
  s.add_dependency "grit"
  s.add_dependency "gitolite"
  s.add_dependency "carrierwave"
  s.add_dependency "six"
  s.add_dependency "redcarpet", "~> 2.1.1"
  s.add_dependency "git"
  s.add_dependency "acts_as_list"
  s.add_dependency "acts-as-taggable-on", "~> 2.1.0"
  s.add_dependency "drapper"
  s.add_dependency "resque", "~> 1.20.0"
  s.add_dependency "httparty"
  s.add_dependency "charlock_holmes"
  s.add_dependency "colored"
  s.add_dependency 'resque_mailer'
  s.add_dependency 'chosen-rails'
  s.add_dependency "graphael-rails",  "0.1.4"

  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
