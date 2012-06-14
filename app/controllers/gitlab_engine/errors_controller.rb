module GitlabEngine
  class ErrorsController < ApplicationController
    layout "gitlab_engine/error"

    def githost
      render "errors/gitolite"
    end
  end
end
