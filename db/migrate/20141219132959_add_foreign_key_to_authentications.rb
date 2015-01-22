class AddForeignKeyToAuthentications < ActiveRecord::Migration
  def change
    add_foreign_key :authentications, :users, on_delete: :cascade
  end
end
