class AddScreenNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :screen_name, :string, null: false
    add_index :users, :screen_name, unique: true
  end
end
