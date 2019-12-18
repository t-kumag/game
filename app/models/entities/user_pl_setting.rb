class Entities::UserPlSetting < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validate  :valid_pl_type
  validate  :valid_group_pl_type

  private

  def valid_pl_type
    return if pl_type.nil?
    errors.add(:pl_type, 'test') unless ['ago', 'since', ''].include?(pl_type)
  end

  def valid_group_pl_type
    return if group_pl_type.nil?
    unless ['ago', 'since', ''].include?(group_pl_type)
      errors.add(:group_pl_type, 'invalid')
    end
  end
end
