class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.references :user, index: true
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :account_name, null: false
      t.string :url

      t.timestamps
    end
  end
end
