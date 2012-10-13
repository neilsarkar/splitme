class MakePlanPricesIntegers < ActiveRecord::Migration
  def up
    change_column :plans, :total_price, :integer
    change_column :plans, :price_per_person, :integer
  end

  def down
    change_column :plans, :total_price, :string
    change_column :plans, :price_per_person, :string
  end
end
