class CreateDms < ActiveRecord::Migration[6.0]
  def change
    create_table :dms do |t|
      t.string :content
      t.integer :sender_id
      t.integer :receiver_id

      t.timestamps
    end
  end
end
