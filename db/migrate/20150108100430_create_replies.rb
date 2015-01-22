class CreateReplies < ActiveRecord::Migration
  def change
    create_table :replies do |t|
      t.references :message, null: false, index: true
      t.integer :to_user_id, null: false
      t.integer :to_message_id

      t.timestamps
    end

    add_foreign_key :replies, :messages,
                    name: 'fk_replies_message_id',
                    on_delete: :cascade
    add_foreign_key :replies, :messages,
                    name: 'fk_replies_to_message_id',
                    column: 'to_message_id',
                    on_delete: :cascade
    add_foreign_key :replies, :users,
                    name: 'fk_replies_to_user_id',
                    column: 'to_user_id',
                    on_delete: :cascade



    add_index :replies, :to_user_id
    add_index :replies, :to_message_id
  end
end
