class AddCardUriToUsersAndDontRequireBankInformation < ActiveRecord::Migration
  def up
    add_column :users, :card_uri, :string
    remove_column :users, :bank_routing_number
    remove_column :users, :bank_account_number
  end

  def down
    remove_column :users, :card_uri
    add_column :users, :bank_routing_number, :string
    add_column :users, :bank_account_number, :string
  end
end
