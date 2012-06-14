module GitlabEngine
  class ProjectsController < ApplicationController
    before_filter :project, :except => [:index, :new, :create]
    layout :determine_layout

    # Authorize
    before_filter :add_project_abilities
    before_filter :authorize_read_project!, :except => [:index, :new, :create]
    before_filter :authorize_admin_project!, :only => [:edit, :update, :destroy]
    before_filter :require_non_empty_project, :only => [:blob, :tree, :graph]

    def new
      @project = Project.new
    end

    def edit
    end

    def create
      @project = Project.create_by_user(params[:project], current_user)

      respond_to do |format|
        if @project.valid?
          format.html { redirect_to @project, notice: 'Project was successfully created.' }
          format.js
        else
          format.html { render action: "new" }
          format.js
        end
      end
    rescue Gitlab::Gitolite::AccessDenied
      render :js => "location.href = '#{errors_githost_path}'" and return
    rescue StandardError => ex
      @project.errors.add(:base, "Cant save project. Please try again later")
      respond_to do |format|
        format.html { render action: "new" }
        format.js
      end
    end

    def update
      respond_to do |format|
        if project.update_attributes(params[:project])
          format.html { redirect_to edit_project_path(project), :notice => 'Project was successfully updated.' }
          format.js
        else
          format.html { render action: "edit" }
          format.js
        end
      end
    end

    def show
      limit = (params[:limit] || 20).to_i
      @events = @project.events.recent.limit(limit)

      respond_to do |format|
        format.html do
          if @project.repo_exists? && @project.has_commits?
            @last_push = current_user.recent_push(@project.id)
            render :show
          else
            render "projects/empty"
          end
        end
      end
    end

    def files
      @notes = @project.notes.where("attachment != 'NULL'").order("created_at DESC").limit(100)
    end

    #
    # Wall
    #

    def wall
      return render_404 unless @project.wall_enabled
      @note = Note.new

      respond_to do |format|
        format.html
      end
    end

    def graph
      @days_json, @commits_json = GraphCommit.to_graph(project)
    end

    def destroy
      # Disable the UsersProject update_repository call, otherwise it will be
      # called once for every person removed from the project
      UsersProject.skip_callback(:destroy, :after, :update_repository)
      project.destroy
      UsersProject.set_callback(:destroy, :after, :update_repository)

      respond_to do |format|
        format.html { redirect_to projects_url }
      end
    end

    protected

    def project
      @project ||= Project.find_by_code(params[:id])
      @project || render_404
    end

    def determine_layout
      if @project && !@project.new_record?
        "gitlab_engine/project"
      else
        "application"
      end
    end
  end
end
