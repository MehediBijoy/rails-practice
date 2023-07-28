class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.numeric :current_amount, null: false, default: 0
      t.numeric :total_payout, null: false, default: 0
      t.integer :lock_version, null: false, default: 0


      t.timestamps
    end
  end
end
