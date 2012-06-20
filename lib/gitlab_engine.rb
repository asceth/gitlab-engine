module GitlabEngine
  module Gitlab
  end
end

#
# gem requires
#
require "acts_as_list"
require "acts-as-taggable-on"

require "bootstrap-sass"

require "carrierwave"
require "charlock_holmes"
require 'chosen-rails'
require "colored"

require "drapper"

require "git"
require "graphael-rails"
require "grit"

require "haml-rails"
require "httparty"

require "jquery-rails"
require "jquery-ui-rails"

require "kaminari"

require "modernizr"

require "redcarpet"
require "resque"
require 'resque_mailer'

require "six"
require "stamp"


#
# gitlab lib/ requires
#
require "file_size_validator"

require "gitlab_engine/color"
require "gitlab_engine/graph_commit"

require "gitlab_engine/gitlab/encode"
require "gitlab_engine/gitlab/gitolite"
require "gitlab_engine/gitlab/git_host"
require "gitlab_engine/gitlab/logger"
require "gitlab_engine/gitlab/merge"
require "gitlab_engine/gitlab/satellite"
require "gitlab_engine/gitlab/theme"

require "gitlab_engine/redcarpet/render/gitlab_html"


#
# Engage.
#
require "gitlab_engine/engine"


