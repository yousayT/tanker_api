class AddLikeusersToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :like_users, :[]
  end
end
