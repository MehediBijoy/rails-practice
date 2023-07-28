class CreateUserDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :user_details do |t|
      t.references :user

      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
