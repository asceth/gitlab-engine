xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom", "xmlns:media" => "http://search.yahoo.com/mrss/" do
  xml.title   "Recent commits to #{@project.name}:#{@ref}"
  xml.link    :href => gitlab_engine.project_commits_url(@project, :atom, :ref => @ref), :rel => "self", :type => "application/atom+xml"
  xml.link    :href => gitlab_engine.project_commits_url(@project), :rel => "alternate", :type => "text/html"
  xml.id      gitlab_engine.project_commits_url(@project)
  xml.updated @commits.first.committed_date.strftime("%Y-%m-%dT%H:%M:%SZ") if @commits.any?

  @commits.each do |commit|
    xml.entry do
      xml.id      gitlab_engine.project_commit_url(@project, :id => commit.id)
      xml.link    :href => gitlab_engine.project_commit_url(@project, :id => commit.id)
      xml.title   truncate(commit.safe_message, :length => 80)
      xml.updated commit.committed_date.strftime("%Y-%m-%dT%H:%M:%SZ")
      xml.media   :thumbnail, :width => "40", :height => "40", :url => gravatar_icon(commit.author_email)
      xml.author do |author|
        xml.name commit.author_name
        xml.email commit.author_email
      end
      xml.summary commit.safe_message
    end
  end
end
