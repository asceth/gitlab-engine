module GitlabEngine
  class Engine < ::Rails::Engine
    isolate_namespace GitlabEngine

    config.to_prepare do
      require 'gitlab_engine/gitlab/gitolite'
      require 'gitlab_engine/gitlab/git_host'
    end
  end
end
