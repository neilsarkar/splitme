class RenameParticipantBalancedPaymentsIdToCardUri < ActiveRecord::Migration
  def up
    rename_column :participants, :balanced_payments_id, :card_uri
  end

  def down
    rename_column :participants, :card_uri, :balanced_payments_id
  end
end
