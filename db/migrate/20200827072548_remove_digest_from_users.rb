class RemoveDigestFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :password_digest, :integer
  end
end
