module GitlabEngine
  class Admin::MailerController < ApplicationController
    layout "gitlab_engine/admin"
    before_filter :authenticate_user!
    before_filter :authenticate_admin!

    def preview

    end

    def preview_note
      @note = Note.first
      @user = @note.author
      @project = @note.project
      case params[:type]
      when "Commit" then
        @commit = @project.commit
        render :file => 'gitlab_engine/notify/note_commit_email', :layout => 'gitlab_engine/notify'
      when "Issue" then
        @issue = Issue.first
        render :file => 'gitlab_engine/notify/note_issue_email', :layout => 'gitlab_engine/notify'
      else
        render :file => 'gitlab_engine/notify/note_wall_email', :layout => 'gitlab_engine/notify'
      end
    rescue
      render :text => "Preview not avaialble"
    end

    def preview_user_new
      @user = User.first
      @password = "DHasJKDHAS!"

      render :file => 'gitlab_engine/notify/new_user_email', :layout => 'gitlab_engine/notify'
    rescue
      render :text => "Preview not avaialble"
    end

    def preview_issue_new
      @issue = Issue.first
      @user = @issue.assignee
      @project = @issue.project
      render :file => 'gitlab_engine/notify/new_issue_email', :layout => 'gitlab_engine/notify'
    rescue
      render :text => "Preview not avaialble"
    end
  end
end
