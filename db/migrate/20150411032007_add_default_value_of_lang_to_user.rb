class AddDefaultValueOfLangToUser < ActiveRecord::Migration
  def change
    change_column :users, :lang, :string, default: 'en'
  end
end
