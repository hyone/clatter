class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :text, null: false
      t.references :user, null: false, index: true
      t.integer :reply_to_id, index: true

      t.timestamps null: false
    end

    add_foreign_key :posts, :users,
                    name: 'fk_messages_user_id',
                    on_delete: :cascade
  end
end
