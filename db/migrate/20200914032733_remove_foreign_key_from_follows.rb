class RemoveForeignKeyFromFollows < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :follows, :users, column: :follower_id
    remove_foreign_key :follows, :users, column: :followee_id
  end
end
