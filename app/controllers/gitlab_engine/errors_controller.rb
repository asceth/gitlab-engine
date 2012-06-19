module GitlabEngine
  class ErrorsController < GitlabEngine::ApplicationController
    layout "gitlab_engine/error"

    def githost
      render "errors/gitolite"
    end
  end
end
