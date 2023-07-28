class CreatePayouts < ActiveRecord::Migration[7.0]
  def change
    create_table :payouts do |t|
      t.numeric :amount
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
