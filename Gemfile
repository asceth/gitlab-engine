source "http://rubygems.org"

gemspec

gem "gitlab_engine", :path => "./"


# GITLAB patched libs
gem "grit",        :git => "https://github.com/gitlabhq/grit.git",            :ref => "7f35cb98ff17d534a07e3ce6ec3d580f67402837"
gem "gitolite",    :git => "https://github.com/gitlabhq/gitolite-client.git", :ref => "9b715ca8bab6529f6c92204a25f84d12f25a6eb0"
gem "pygments.rb", :git => "https://github.com/gitlabhq/pygments.rb.git",     :ref => "2cada028da5054616634a1d9ca6941b65b3ce188"
gem 'yaml_db',     :git => "https://github.com/gitlabhq/yaml_db.git"
gem 'grack',       :git => "https://github.com/gitlabhq/grack.git"
gem "linguist", "~> 1.0.0", :git => "https://github.com/gitlabhq/linguist.git"


gem 'devise', '2.1.0'


group :assets do
  gem 'uglifier'
  # in gemspec
  #
  # bootstrap-sass
  # chosen-rails
  # jquery-rails
  # jquery-ui-rails
  # modernizr
  # raphael-rails
end

group :development, :test do
  gem "awesome_print"

  gem "capybara"
  gem "capybara-webkit", :git => "https://github.com/thoughtbot/capybara-webkit.git"
  gem "coffee-rails"

  gem "database_cleaner"

  gem "faker"

  gem "launchy"

  gem "shoulda", "~> 3.0.0"
  gem "sqlite3"

  gem "pg"
  gem "pry"

  gem "rspec-rails"

  gem "webmock"
end

group :test do
  gem 'cucumber-rails', :require => false

  gem 'email_spec'

  gem 'minitest', ">= 2.10"

  gem 'resque_spec'

  gem "simplecov", :require => false
  gem "shoulda-matchers"

  gem "turn", :require => false
end
