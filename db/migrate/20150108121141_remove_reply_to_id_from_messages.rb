class RemoveReplyToIdFromMessages < ActiveRecord::Migration
  def change
    remove_column :messages, :reply_to_id
  end
end
