class AddBalancedFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :street_address, :string
    add_column :users, :zip_code, :string
    add_column :users, :date_of_birth, :string
  end
end
