class RenamePostsToMessages < ActiveRecord::Migration
  def change
    rename_table :posts, :messages
  end
end
