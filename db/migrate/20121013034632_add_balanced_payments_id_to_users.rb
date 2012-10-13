class AddBalancedPaymentsIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :balanced_payments_id, :string
  end
end
