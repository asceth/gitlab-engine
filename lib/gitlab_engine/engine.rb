module GitlabEngine
  class Engine < ::Rails::Engine
    isolate_namespace GitlabEngine

    config.active_record.observers = ['GitlabEngine::MailerObserver', 'GitlabEngine::ActivityObserver']

    config.to_prepare do
      #
      # initializers...
      #
      ::GIT_HOST = YAML.load_file("#{Rails.root}/config/gitlab.yml")["git_host"]
      ::EMAIL_OPTS = YAML.load_file("#{Rails.root}/config/gitlab.yml")["email"]
      ::GIT_OPTS = YAML.load_file("#{Rails.root}/config/gitlab.yml")["git"]

      require "gitlab_engine/initializers/20_grit_ext"
      require "gitlab_engine/initializers/30_resque_queues"
    end
  end
end
