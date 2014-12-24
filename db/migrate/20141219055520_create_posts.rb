class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :text, null: false
      t.references :user, null: false, index: true
      t.integer :reply_to_id, index: true

      t.foreign_key :users, dependent: :delete
      t.foreign_key :posts, column: 'reply_to_id'

      t.timestamps
    end
  end
end
