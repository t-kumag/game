class AddColumnToPairingRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :pairing_requests, :pairing_token_expires_at, :datetime, after: :token
  end
end
