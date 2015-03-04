class AddCounterCultureFieldsToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :favorited_count, :integer, null: false, default: 0
    add_column :messages, :retweeted_count, :integer, null: false, default: 0
  end
end
