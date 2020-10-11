class AddIndexToDms < ActiveRecord::Migration[6.0]
  def change
    add_index :dms, [:sender_id, :receiver_id], name: :dms_idx
  end
end
