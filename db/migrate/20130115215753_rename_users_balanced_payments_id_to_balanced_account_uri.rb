class RenameUsersBalancedPaymentsIdToBalancedAccountUri < ActiveRecord::Migration
  def up
    User.all.each do |user|
      user.balanced_payments_id = user.balanced_account.try(:uri)
      user.save
    end

    rename_column :users, :balanced_payments_id, :balanced_account_uri
  end

  def down
    User.all.each do |user|
      user.balanced_account_uri = user.balanced_account.try(:id)
      user.save
    end
    rename_column :users, :balanced_account_uri, :balanced_payments_id
  end
end
