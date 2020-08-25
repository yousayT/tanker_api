class CopyMigration < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :is_admin, :boolean, default: false
    change_column :users, :image_name, :string, default: "default.jpg"
    change_column :posts, :likes_count, :integer, default: 0
    add_foreign_key :follows, :users, column: :follower_id
    add_foreign_key :follows, :users, column: :followee_id
  end
end
