require 'digest/md5'

module GitlabEngine
  module ApplicationHelper
    def gravatar_icon(user_email = '', size = 40)
      return unless user_email
      gravatar_host = request.ssl? ? "https://secure.gravatar.com" :  "http://www.gravatar.com"
      user_email.strip!
      "#{gravatar_host}/avatar/#{Digest::MD5.hexdigest(user_email.downcase)}?s=#{size}&d=identicon"
    end

    def request_protocol
      request.ssl? ? "https" : "http"
    end

    def web_app_url
      "#{request_protocol}://#{GitlabEngine::Gitlab.config.web_host}/"
    end

    def last_commit(project)
      if project.repo_exists?
        time_ago_in_words(project.commit.committed_date) + " ago"
      else
        "Never"
      end
    rescue
      "Never"
    end

    def grouped_options_refs(destination = :tree)
      options = [
                 ["Branch", @project.repo.heads.map(&:name) ],
                 [ "Tag", @project.tags ]
                ]

      # If reference is commit id -
      # we should add it to branch/tag selectbox
      if(@ref && !options.flatten.include?(@ref) &&
         @ref =~ /^[0-9a-zA-Z]{6,52}$/)
        options << ["Commit", [@ref]]
      end

      grouped_options_for_select(options, @ref || @project.default_branch)
    end

    def markdown(text)
      @__renderer ||= Redcarpet::Markdown.new(Redcarpet::Render::GitlabHTML.new(filter_html: true), {
                                                no_intra_emphasis: true,
                                                tables: true,
                                                fenced_code_blocks: true,
                                                autolink: true,
                                                strikethrough: true,
                                                lax_html_blocks: true,
                                                space_after_headers: true,
                                                superscript: true
                                              })

      @__renderer.render(text).html_safe
    end

    def search_autocomplete_source
      projects = current_user.projects.map{ |p| { :label => p.name, :url => gitlab_engine.project_path(p) } }
      default_nav = [
                     { :label => "Profile", :url => gitlab_engine.profile_path },
                     { :label => "Keys", :url => gitlab_engine.keys_path },
                     { :label => "Dashboard", :url => root_path },
                     { :label => "Admin", :url => gitlab_engine.admin_root_path }
                    ]

      project_nav = []

      if @project && !@project.new_record?
        project_nav = [
                       { :label => "#{@project.name} / Issues", :url => gitlab_engine.project_issues_path(@project) },
                       { :label => "#{@project.name} / Wall", :url => gitlab_engine.wall_project_path(@project) },
                       { :label => "#{@project.name} / Tree", :url => gitlab_engine.tree_project_ref_path(@project, @project.root_ref) },
                       { :label => "#{@project.name} / Commits", :url => gitlab_engine.project_commits_path(@project) },
                       { :label => "#{@project.name} / Team", :url => gitlab_engine.project_team_members_path(@project) }
                      ]
      end

      [projects, default_nav, project_nav].flatten.to_json
    end

    def app_theme
      GitlabEngine::Gitlab::Theme.css_class_by_id(current_user.try(:theme_id))
    end

    def show_last_push_widget?(event)
      event && event.last_push_to_non_root? && !event.rm_ref? && event.project && event.project.merge_requests_enabled
    end

    def tab_class(tab_key)
      active = case tab_key

                 # Project Area
               when :wall; wall_tab?
               when :wiki; controller.controller_name == "wikis"
               when :issues; issues_tab?
               when :network; current_page?(:controller => "projects", :action => "graph", :id => @project)
               when :merge_requests; controller.controller_name == "merge_requests"

                 # Dashboard Area
               when :help; controller.controller_name == "help"
               when :search; current_page?(search_path)
               when :dash_issues; current_page?(dashboard_issues_path)
               when :dash_mr; current_page?(dashboard_merge_requests_path)
               when :root; current_page?(dashboard_path) || current_page?(root_path)

                 # Profile Area
               when :profile;  current_page?(:controller => "profile", :action => :show)
               when :password; current_page?(:controller => "profile", :action => :password)
               when :token;    current_page?(:controller => "profile", :action => :token)
               when :design;   current_page?(:controller => "profile", :action => :design)
               when :ssh_keys; controller.controller_name == "keys"

                 # Admin Area
               when :admin_root;     controller.controller_name == "dashboard"
               when :admin_users;    controller.controller_name == 'users'
               when :admin_projects; controller.controller_name == "projects"
               when :admin_emails;   controller.controller_name == 'mailer'
               when :admin_resque;   controller.controller_name == 'resque'
               when :admin_logs;   controller.controller_name == 'logs'

               else
                 false
               end
      active ? "current" : nil
    end

    def hexdigest(string)
      Digest::SHA1.hexdigest string
    end
  end
end
