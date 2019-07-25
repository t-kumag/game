# == Schema Information
#
# Table name: user_distributed_transactions
#
#  id                                   :bigint(8)        not null, primary key
#  user_id                              :bigint(8)
#  group_id                             :bigint(8)
#  share                                :boolean
#  used_date                            :date             not null
#  at_user_bank_transaction_id          :bigint(8)
#  at_user_card_transaction_id          :bigint(8)
#  at_user_emoney_transaction_id        :bigint(8)
#  user_manually_created_transaction_id :bigint(8)
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  used_location                        :string(255)
#  amount                               :integer
#  at_transaction_category_id           :bigint(8)
#

class Entities::UserDistributedTransaction < ApplicationRecord
  belongs_to :user_manually_created_transaction, optional: true
  belongs_to :at_user_card_transaction, optional: true
  belongs_to :at_user_bank_transaction, optional: true
  belongs_to :at_user_emoney_transaction, optional: true

  validates :at_transaction_category_id, presence: true, on: :update

  def user_pl

    share = params[:share]

    from = Time.zone.today.beginning_of_month
    to = Time.zone.today.end_of_month

    u = self.left_joins(:user_manually_created_transaction).
    left_joins(:at_user_card_transaction).
    left_joins(:at_user_bank_transaction).
    left_joins(:at_user_emoney_transaction).
    where(user_distributed_transaction: { used_date: from..to, user_id: @current_user.id, share: share})

    #  user_id                              :bigint(8)
#  group_id                             :bigint(8)
#  share                                :boolean

    # UserDistributedTransaction.left_joins(:user_manually_created_transaction).left_joins(:at_user_card_transaction).left_joins(:at_user_bank_transaction).left_joins(:at_user_emoney_transaction).where(user_distributed_transaction: { id: nil })
  end

  def group_pl
    share = params[:share]

    from = Time.zone.today.beginning_of_month
    to = Time.zone.today.end_of_month

    u = self.left_joins(:user_manually_created_transaction).
    left_joins(:at_user_card_transaction).
    left_joins(:at_user_bank_transaction).
    left_joins(:at_user_emoney_transaction).
    where(user_distributed_transaction: { used_date: from..to, group_id: @current_user.group.id, share: share})

    #  user_id                              :bigint(8)
#  group_id                             :bigint(8)
#  share                                :boolean

    # UserDistributedTransaction.left_joins(:user_manually_created_transaction).left_joins(:at_user_card_transaction).left_joins(:at_user_bank_transaction).left_joins(:at_user_emoney_transaction).where(user_distributed_transaction: { id: nil })
  end

end
