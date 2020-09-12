class RemoveDefaultFromImageNameInUsers < ActiveRecord::Migration[6.0]
  def change
    change_column_default :users, :image_name, nil
  end
end
