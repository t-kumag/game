class Entities::UserDistributedTransaction < ApplicationRecord
  belongs_to :user_manually_created_transaction
end
