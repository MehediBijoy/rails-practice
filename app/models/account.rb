class Account < ApplicationRecord

  has_many :payouts

  def self.ignored_columns = %w[lock_version]
  def self.lock_optimistically = true

  validates :current_amount, numericality: { greater_than_or_equal_to: 0 }

  def payout!(amount:)
    self.class.transaction do
      payouts_object = payouts.create!(amount:)
      with_lock do
        sleep(10)
        self.current_amount -= amount
        self.total_payout += amount
        self.save!
      end
      payouts_object
    end
  end

end
