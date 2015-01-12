class CreateReplies < ActiveRecord::Migration
  def change
    create_table :replies do |t|
      t.references :message, null: false, index: true
      t.integer :to_user_id, null: false
      t.integer :to_message_id

      t.foreign_key :messages, dependent: :delete
      t.foreign_key :messages, column: 'to_message_id', dependent: :delete
      t.foreign_key :users, column: 'to_user_id', dependent: :delete

      t.timestamps
    end

    add_index :replies, :to_user_id
    add_index :replies, :to_message_id
  end
end
