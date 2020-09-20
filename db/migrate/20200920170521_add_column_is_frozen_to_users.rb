class AddColumnIsFrozenToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_frozen, :boolean, default: false
  end
end
