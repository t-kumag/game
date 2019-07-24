class AddColumnToPairingRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :pairing_requests, :token_expires_at, :datetime, after: :token
  end
end
