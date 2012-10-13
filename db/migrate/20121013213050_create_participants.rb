class CreateParticipants < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone_number, null: false
      t.string :balanced_payments_id, null: false
      t.string :card_type

      t.timestamps
    end
  end
end
