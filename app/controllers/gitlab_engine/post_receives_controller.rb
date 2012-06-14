module GitlabEngine
  class PostReceivesController < ApplicationController
    skip_before_filter :verify_authenticity_token

    def create
      Resque.enqueue(PostReceive,
                     params[:reponame],
                     params[:oldrev],
                     params[:newrev],
                     params[:ref],
                     params[:gl_user])

      render :nothing => true
    end
  end
end
