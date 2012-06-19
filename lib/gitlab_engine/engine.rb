module GitlabEngine
  class Engine < ::Rails::Engine
    isolate_namespace GitlabEngine

    config.active_record.observers = ['GitlabEngine::MailerObserver']

    config.to_prepare do
      #
      # initializers...
      #
      require "gitlab_engine/initializers/20_grit_ext"
      require "gitlab_engine/initializers/30_resque_queues"
    end
  end
end
