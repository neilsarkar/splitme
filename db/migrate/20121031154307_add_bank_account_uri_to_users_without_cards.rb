class AddBankAccountUriToUsersWithoutCards < ActiveRecord::Migration
  def up
    User.where(card_uri: nil).each do |user|
      user.bank_account_uri = user.balanced_account.bank_accounts.first.uri
      user.save
    end
  end

  def down
    execute "update users set bank_account_uri = null"
  end
end
