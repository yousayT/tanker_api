class AddColumnIsReadToDms < ActiveRecord::Migration[6.0]
  def change
    add_column :dms, :is_read, :boolean, default: false
  end
end
