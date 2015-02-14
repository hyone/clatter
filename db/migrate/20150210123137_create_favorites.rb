class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.references :user,    null: false, index: true
      t.references :message, null: false, index: true

      t.timestamps null: false
    end

    add_foreign_key :favorites, :users,
                    name: 'fk_favorites_user_id',
                    on_delete: :cascade
    add_foreign_key :favorites, :messages,
                    name: 'fk_favorites_message_id',
                    on_delete: :cascade

    add_index :favorites, [:user_id, :message_id], unique: true
  end
end
