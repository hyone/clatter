class AddForeignKeyToAuthentications < ActiveRecord::Migration
  def change
    change_table :authentications do |t|
      t.foreign_key :users, dependent: :delete
    end
  end
end
