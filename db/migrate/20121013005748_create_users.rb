class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone_number, null: false
      t.string :bank_routing_number, null: false
      t.string :bank_account_number, null: false
      t.string :token
      t.string :password_digest

      t.timestamps
    end

    add_index :users, :token, unique: true
  end
end
