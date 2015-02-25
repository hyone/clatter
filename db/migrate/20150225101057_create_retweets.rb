class CreateRetweets < ActiveRecord::Migration
  def change
    create_table :retweets do |t|
      t.references :user,    null: false, index: true
      t.references :message, null: false, index: true

      t.timestamps null: false
    end
    add_foreign_key :retweets, :users,
                    name: 'fk_retweets_user_id',
                    on_delete: :cascade
    add_foreign_key :retweets, :messages,
                    name: 'fk_retweets_message_id',
                    on_delete: :cascade

    add_index :retweets, [:user_id, :message_id], unique: true
  end
end
