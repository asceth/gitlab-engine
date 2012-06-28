module GitlabEngine
  module IssuesHelper
    def project_issues_filter_path project, params = {}
      params[:f] ||= cookies['issue_filter']
      gitlab_engine.project_issues_path project, params
    end

    def link_to_issue_assignee(issue)
      project = issue.project

      tm = project.team_member_by_id(issue.assignee_id)
      if tm
        link_to issue.assignee_name, gitlab_engine.project_team_member_path(project, tm), :class => "author_link"
      else
        issue.assignee_name
      end
    end

    def link_to_issue_author(issue)
      project = issue.project

      tm = project.team_member_by_id(issue.author_id)
      if tm
        link_to issue.author_name, gitlab_engine.project_team_member_path(project, tm), :class => "author_link"
      else
        issue.author_name
      end
    end

    def issue_css_classes(issue)
      classes = ["issue"]
      classes << "closed" if issue.closed
      classes << "today" if issue.today?
      classes.join(' ')
    end

    def issue_tags
      @project.issues.tag_counts_on(:labels).map(&:name)
    end
  end
end
