class AddBankAccountUriToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bank_account_uri, :string
  end
end
