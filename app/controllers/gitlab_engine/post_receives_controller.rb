module GitlabEngine
  class PostReceivesController < GitlabEngine::ApplicationController
    skip_before_filter :authenticate_user!
    skip_before_filter :reject_blocked!
    skip_before_filter :set_current_user_for_mailer
    skip_before_filter :check_token_auth
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
