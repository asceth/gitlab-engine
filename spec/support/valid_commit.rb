module ValidCommit
  ID = "211ef121f81ded2a7ea6aab81999ee51a47f8e03"
  MESSAGE = "fixing stack level too deep error"
  AUTHOR_FULL_NAME = "John Long"

  FILES = [".gitignore", "Gemfile", "Gemfile.lock", "MIT-LICENSE", "README.rdoc", "Rakefile", "app", "config", "gitlab-engine.gemspec", "lib", "script", "test"]
  FILES_COUNT = 12

  C_FILE_PATH = "app/models"
  C_FILES = ["commit.rb", "event.rb", "issue.rb", "key.rb", "key_observer.rb", "merge_request.rb", "milestone.rb", "note.rb", "project.rb", "project_observer.rb", "protected_branch.rb", "snippet.rb", "tree.rb", "web_hook.rb", "wiki.rb"]

  BLOB_FILE = %{%h3= @key.title\n%hr\n%pre= @key.key\n.actions\n  = link_to 'Remove', @key, :confirm => 'Are you sure?', :method => :delete, :class => \"btn danger delete-key\"\n\n\n}
  BLOB_FILE_PATH = "app/views/keys/show.html.haml"
end

