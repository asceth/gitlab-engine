class InitialSchema < ActiveRecord::Migration
  def change
    create_table "events" do |t|
      t.string   "target_type"
      t.integer  "target_id"
      t.string   "title"
      t.text     "data"
      t.integer  "project_id"
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
      t.integer  "action"
      t.integer  "author_id"
    end

    create_table "issues" do |t|
      t.string   "title"
      t.integer  "assignee_id"
      t.integer  "author_id"
      t.integer  "project_id"
      t.datetime "created_at",                      :null => false
      t.datetime "updated_at",                      :null => false
      t.boolean  "closed",       :default => false, :null => false
      t.integer  "position",     :default => 0
      t.boolean  "critical",     :default => false, :null => false
      t.string   "branch_name"
      t.text     "description"
      t.integer  "milestone_id"
    end

    add_index "issues", ["project_id"], :name => "index_issues_on_project_id"

    create_table "keys" do |t|
      t.integer  "user_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
      t.text     "key"
      t.string   "title"
      t.string   "identifier"
      t.integer  "project_id"
    end

    create_table "merge_requests" do |t|
      t.string   "target_branch",                                          :null => false
      t.string   "source_branch",                                          :null => false
      t.integer  "project_id",                                             :null => false
      t.integer  "author_id"
      t.integer  "assignee_id"
      t.string   "title"
      t.boolean  "closed",                              :default => false, :null => false
      t.datetime "created_at",                                             :null => false
      t.datetime "updated_at",                                             :null => false
      t.text     "st_commits"
      t.text     "st_diffs"
      t.boolean  "merged",                              :default => false, :null => false
      t.integer  "state",                               :default => 1,     :null => false
    end

    add_index "merge_requests", ["project_id"], :name => "index_merge_requests_on_project_id"

    create_table "milestones" do |t|
      t.string   "title",                          :null => false
      t.integer  "project_id",                     :null => false
      t.text     "description"
      t.date     "due_date"
      t.boolean  "closed",      :default => false, :null => false
      t.datetime "created_at",                     :null => false
      t.datetime "updated_at",                     :null => false
    end

    create_table "notes" do |t|
      t.text     "note"
      t.integer   "noteable_id"
      t.string   "noteable_type"
      t.integer  "author_id"
      t.datetime "created_at",    :null => false
      t.datetime "updated_at",    :null => false
      t.integer  "project_id"
      t.string   "attachment"
      t.string   "line_code"
    end

    add_index "notes", ["noteable_id"], :name => "index_notes_on_noteable_id"
    add_index "notes", ["noteable_type"], :name => "index_notes_on_noteable_type"

    create_table "projects" do |t|
      t.string   "name"
      t.string   "path"
      t.text     "description"
      t.datetime "created_at",                                   :null => false
      t.datetime "updated_at",                                   :null => false
      t.boolean  "private_flag",           :default => true,     :null => false
      t.string   "code"
      t.integer  "owner_id"
      t.string   "default_branch",         :default => "master", :null => false
      t.boolean  "issues_enabled",         :default => true,     :null => false
      t.boolean  "wall_enabled",           :default => true,     :null => false
      t.boolean  "merge_requests_enabled", :default => true,     :null => false
      t.boolean  "wiki_enabled",           :default => true,     :null => false
    end

    create_table "protected_branches" do |t|
      t.integer  "project_id", :null => false
      t.string   "name",       :null => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    create_table "snippets" do |t|
      t.string   "title"
      t.text     "content"
      t.integer  "author_id",  :null => false
      t.integer  "project_id", :null => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
      t.string   "file_name"
      t.datetime "expires_at"
    end

    create_table "taggings" do |t|
      t.integer  "tag_id"
      t.integer  "taggable_id"
      t.string   "taggable_type"
      t.integer  "tagger_id"
      t.string   "tagger_type"
      t.string   "context"
      t.datetime "created_at"
    end

    add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
    add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

    create_table "tags" do |t|
      t.string "name"
    end

    create_table "users_projects" do |t|
      t.integer  "user_id",                       :null => false
      t.integer  "project_id",                    :null => false
      t.datetime "created_at",                    :null => false
      t.datetime "updated_at",                    :null => false
      t.integer  "project_access", :default => 0, :null => false
    end

    create_table "web_hooks" do |t|
      t.string   "url"
      t.integer  "project_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    create_table "wikis" do |t|
      t.string   "title"
      t.text     "content"
      t.integer  "project_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
      t.string   "slug"
      t.integer  "user_id"
    end

    # special user columns
    [
     [:name,                 :string,  {:default => false, :null => false}],
     [:admin,                :boolean, {:default => false, :null => false}],
     [:projects_limit,       :integer, {:default => 10}],
     [:skype,                :string,  {:default => "", :null => false}],
     [:linkedin,             :string,  {:default => "",    :null => false}],
     [:twitter,              :string,  {:default => "", :null => false}],
     [:dark_scheme,          :boolean, {:default => false, :null => false}],
     [:theme_id,             :integer, {:default => 1, :null => false}],
     [:bio,                  :text,     {}],
     [:blocked,              :boolean, {:default => false, :null => false}]
    ].each do |(name, type, options)|
      add_column(:users, name, type, options)
    end
  end
end

