module GitlabEngine
  class MergeRequestsController < GitlabEngine::ApplicationController
    before_filter :authenticate_user!
    before_filter :project
    before_filter :module_enabled
    before_filter :merge_request, :only => [:edit, :update, :destroy, :show, :commits, :diffs, :automerge, :automerge_check]
    layout "gitlab_engine/project"

    # Authorize
    before_filter :add_project_abilities

    # Allow read any merge_request
    before_filter :authorize_read_merge_request!

    # Allow write(create) merge_request
    before_filter :authorize_write_merge_request!, :only => [:new, :create]

    # Allow modify merge_request
    before_filter :authorize_modify_merge_request!, :only => [:close, :edit, :update, :sort]

    # Allow destroy merge_request
    before_filter :authorize_admin_merge_request!, :only => [:destroy]

    def index
      @merge_requests = @project.merge_requests

      @merge_requests = case params[:f].to_i
                        when 1 then @merge_requests
                        when 2 then @merge_requests.closed
                        when 3 then @merge_requests.opened.assigned(current_user)
                        else @merge_requests.opened
                        end.page(params[:page]).per(20)

      @merge_requests = @merge_requests.includes(:author, :project).order("closed, created_at desc")
    end

    def show
      # Show git not found page if target branch doesnt exist
      return git_not_found! unless @project.repo.heads.map(&:name).include?(@merge_request.target_branch)

      # Show git not found page if source branch doesnt exist
      # and there is no saved commits between source & target branch
      return git_not_found! if !@project.repo.heads.map(&:name).include?(@merge_request.source_branch) && @merge_request.commits.blank?

      # Build a note object for comment form
      @note = @project.notes.new(:noteable => @merge_request)

      # Get commits from repository
      # or from cache if already merged
      @commits = @merge_request.commits

      respond_to do |format|
        format.html
        format.js
      end
    end

    def diffs
      @diffs = @merge_request.diffs
      @commit = @merge_request.last_commit

      @comments_allowed = true
      @line_notes = @merge_request.notes.where("line_code is not null")
    end

    def new
      @merge_request = @project.merge_requests.new(params[:merge_request])
    end

    def edit
    end

    def create
      @merge_request = @project.merge_requests.new(params[:merge_request])
      @merge_request.author = current_user

      if @merge_request.save
        @merge_request.reload_code
        redirect_to [@project, @merge_request], notice: 'Merge request was successfully created.'
      else
        render action: "new"
      end
    end

    def update
      if @merge_request.update_attributes(params[:merge_request].merge(:author_id_of_changes => current_user.id))
        @merge_request.reload_code
        @merge_request.mark_as_unchecked
        redirect_to [@project, @merge_request], notice: 'Merge request was successfully updated.'
      else
        render action: "edit"
      end
    end

    def automerge_check
      if @merge_request.unchecked?
        @merge_request.check_if_can_be_merged
      end
      render :json => {:state => @merge_request.human_state}
    end

    def automerge
      return access_denied! unless can?(current_user, :accept_mr, @project)
      if @merge_request.open? && @merge_request.can_be_merged?
        @merge_request.should_remove_source_branch = params[:should_remove_source_branch]
        @merge_request.automerge!(current_user)
        @status = true
      else
        @status = false
      end
    end

    def destroy
      @merge_request.destroy

      respond_to do |format|
        format.html { redirect_to project_merge_requests_url(@project) }
      end
    end

    def branch_from
      @commit = project.commit(params[:ref])
    end

    def branch_to
      @commit = project.commit(params[:ref])
    end

    protected

    def merge_request
      @merge_request ||= @project.merge_requests.find(params[:id])
    end

    def authorize_modify_merge_request!
      return render_404 unless can?(current_user, :modify_merge_request, @merge_request)
    end

    def authorize_admin_merge_request!
      return render_404 unless can?(current_user, :admin_merge_request, @merge_request)
    end

    def module_enabled
      return render_404 unless @project.merge_requests_enabled
    end
  end
end
