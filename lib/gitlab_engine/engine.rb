module GitlabEngine
  class Engine < ::Rails::Engine
    isolate_namespace GitlabEngine

    config.active_record.observers = ['GitlabEngine::MailerObserver']
  end
end
