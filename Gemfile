source "http://rubygems.org"

gemspec

gem "gitlab_engine", :path => "./"


# jquery-rails is used by the dummy application
gem "jquery-rails"


# GITLAB patched libs
gem "grit",        :git => "https://github.com/gitlabhq/grit.git",            :ref => "7f35cb98ff17d534a07e3ce6ec3d580f67402837"
gem "gitolite",    :git => "https://github.com/gitlabhq/gitolite-client.git", :ref => "9b715ca8bab6529f6c92204a25f84d12f25a6eb0"
gem "pygments.rb", :git => "https://github.com/gitlabhq/pygments.rb.git",     :ref => "2cada028da5054616634a1d9ca6941b65b3ce188"
gem 'yaml_db',     :git => "https://github.com/gitlabhq/yaml_db.git"
gem "linguist", "~> 1.0.0", :git => "https://github.com/gitlabhq/linguist.git"


gem 'devise', '2.1.0'


group :development, :test do
  gem "launchy"
  gem "jquery-rails"
  gem "coffee-rails"
  gem "faker"
  gem "pg"
  gem "sqlite3"
  gem "rspec-rails"
  gem "shoulda", "~> 3.0.0"
  gem "capybara", :git => "https://github.com/jnicklas/capybara.git"
  gem "capybara-webkit"
  gem "autotest"
  gem "autotest-rails"
  gem "pry"
  gem "awesome_print"
  gem "database_cleaner"
  gem "launchy"
  gem "webmock"
end

group :test do
  gem 'cucumber-rails', :require => false
  gem 'minitest', ">= 2.10"
  gem "turn", :require => false
  gem "simplecov", :require => false
  gem "shoulda-matchers"
  gem 'email_spec'
end
