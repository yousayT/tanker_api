class RemovePasswordFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :password, :integer
  end
end
