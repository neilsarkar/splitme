class AddStateToCommitments < ActiveRecord::Migration
  def change
    add_column :commitments, :state, :string, null: false, default: "unpaid"
  end
end
