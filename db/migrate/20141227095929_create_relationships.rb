class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps null: false
    end

    add_foreign_key :relationships, :users,
                    name: 'fk_relationships_follower_id',
                    column: 'follower_id',
                    on_delete: :cascade
    add_foreign_key :relationships, :users,
                    name: 'fk_relationships_followed_id',
                    column: 'followed_id',
                    on_delete: :cascade

    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end
