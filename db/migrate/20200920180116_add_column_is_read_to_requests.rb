class AddColumnIsReadToRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :is_read, :boolean, default: false
  end
end
