class AddIndexPairingRequestsToken < ActiveRecord::Migration[5.2]
  def change
    add_index :pairing_requests, :token, :unique=>true
  end
end
