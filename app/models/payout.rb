class Payout < ApplicationRecord
  belongs_to :account

  validate :check_amount

  def check_amount
    errors.add(:amount, 'amount is not valid') if account.current_amount < amount
  end
end
