class AddCounterCultureFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :messages_count,  :integer, null: false, default: 0
    add_column :users, :following_count, :integer, null: false, default: 0
    add_column :users, :followers_count, :integer, null: false, default: 0
    add_column :users, :favorites_count, :integer, null: false, default: 0
  end
end
