class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :password
      t.boolean :is_admin
      t.string :uid
      t.string :image_name
      t.string :profile
      t.string :token

      t.timestamps
    end
  end
end
