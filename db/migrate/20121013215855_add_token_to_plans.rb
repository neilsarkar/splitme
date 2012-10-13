class AddTokenToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :token, :string
    add_index :plans, :token, unique: true
  end
end
