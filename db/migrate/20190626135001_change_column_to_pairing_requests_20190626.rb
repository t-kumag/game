class ChangeColumnToPairingRequests20190626 < ActiveRecord::Migration[5.2]
  def up
    change_column :pairing_requests, :status, :bigint, null: false, default: 0
  end

  def down
    change_column :pairing_requests, :status
  end
end
