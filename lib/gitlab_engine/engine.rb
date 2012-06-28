module GitlabEngine
  class Engine < ::Rails::Engine
    isolate_namespace GitlabEngine

    config.active_record.observers = [
                                      'GitlabEngine::ActivityObserver'
                                      'GitlabEngine::IssueObserver'
                                      'GitlabEngine::KeyObserver'
                                      'GitlabEngine::MailerObserver'
                                      'GitlabEngine::ProjectObserver'
                                      'GitlabEngine::UserObserver'
                                     ]

    config.to_prepare do
      #
      # initializers...
      #
      ::GIT_HOST = YAML.load_file("#{Rails.root}/config/gitlab.yml")["git_host"]
      ::EMAIL_OPTS = YAML.load_file("#{Rails.root}/config/gitlab.yml")["email"]
      ::GIT_OPTS = YAML.load_file("#{Rails.root}/config/gitlab.yml")["git"]
      ::GITLAB_SATELLITE = YAML.load_file("#{Rails.root}/config/gitlab.yml")["satellite"]

      Resque::Mailer.excluded_environments = []

      require "gitlab_engine/initializers/20_grit_ext"
      require "gitlab_engine/initializers/30_resque_queues"
    end
  end
end
