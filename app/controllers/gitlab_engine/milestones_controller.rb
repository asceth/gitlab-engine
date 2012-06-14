module GitlabEngine
  class MilestonesController < ApplicationController
    before_filter :authenticate_user!
    before_filter :project
    before_filter :module_enabled
    before_filter :milestone, :only => [:edit, :update, :destroy, :show]
    layout "gitlab_engine/project"

    # Authorize
    before_filter :add_project_abilities

    # Allow read any milestone
    before_filter :authorize_read_milestone!

    # Allow admin milestone
    before_filter :authorize_admin_milestone!, :except => [:index, :show]

    respond_to :html

    def index
      @milestones = case params[:f].to_i
                    when 1; @project.milestones
                    else @project.milestones.active
                    end

      @milestones = @milestones.includes(:project).order("due_date")
      @milestones = @milestones.page(params[:page]).per(20)
    end

    def new
      @milestone = @project.milestones.new
      respond_with(@milestone)
    end

    def edit
      respond_with(@milestone)
    end

    def show
      @issues = @milestone.issues.opened.page(params[:page]).per(40)
      @users = @milestone.participants

      respond_to do |format|
        format.html
        format.js
      end
    end

    def create
      @milestone = @project.milestones.new(params[:milestone])

      if @milestone.save
        redirect_to project_milestone_path(@project, @milestone)
      else
        render "new"
      end
    end

    def update
      @milestone.update_attributes(params[:milestone])

      respond_to do |format|
        format.js
        format.html do
          if @milestone.valid?
            redirect_to [@project, @milestone]
          else
            render :edit
          end
        end
      end
    end

    def destroy
      return access_denied! unless can?(current_user, :admin_milestone, @milestone)

      @milestone.destroy

      respond_to do |format|
        format.html { redirect_to project_milestones_path }
        format.js { render :nothing => true }
      end
    end

    protected

    def milestone
      @milestone ||= @project.milestones.find(params[:id])
    end

    def authorize_admin_milestone!
      return render_404 unless can?(current_user, :admin_milestone, @project)
    end

    def module_enabled
      return render_404 unless @project.issues_enabled
    end
  end
end
