class AddDebitUriToCommitments < ActiveRecord::Migration
  def change
    add_column :commitments, :debit_uri, :string
  end
end
