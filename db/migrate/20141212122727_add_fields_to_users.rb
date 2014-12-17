class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string, null: false
    add_column :users, :description, :string, limit: 160
    add_column :users, :url, :string
  end
end
