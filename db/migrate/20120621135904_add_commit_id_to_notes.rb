class AddCommitIdToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :commit_id, :string
  end
end

