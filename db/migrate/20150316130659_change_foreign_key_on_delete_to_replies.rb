class ChangeForeignKeyOnDeleteToReplies < ActiveRecord::Migration
  def change
    remove_foreign_key :replies, column: 'to_message_id'
    add_foreign_key :replies, :messages,
                    name: 'fk_replies_to_message_id',
                    column: 'to_message_id',
                    on_delete: :nullify
  end
end
