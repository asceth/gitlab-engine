module GitlabEngine
  class Engine < ::Rails::Engine
    isolate_namespace GitlabEngine

    config.active_record.observers = [
                                      'GitlabEngine::ActivityObserver',
                                      'GitlabEngine::IssueObserver',
                                      'GitlabEngine::KeyObserver',
                                      'GitlabEngine::MailerObserver',
                                      'GitlabEngine::ProjectObserver',
                                      'GitlabEngine::UserObserver'
                                     ]

    config.to_prepare do
      #
      # initializers...
      #
      Resque::Mailer.excluded_environments = []

      require "gitlab_engine/initializers/10_settings"
      require "gitlab_engine/initializers/20_grit_ext"
      require "gitlab_engine/initializers/30_resque_queues"
    end
  end
end
