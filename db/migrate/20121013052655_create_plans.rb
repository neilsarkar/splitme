class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :title, null: false
      t.text :description
      t.integer :total_price
      t.integer :price_per_person
      t.integer :user_id, null: false

      t.timestamps
    end

    add_index :plans, :user_id
  end
end
