class ConnectCommitmentsToUsers < ActiveRecord::Migration
  def up
    Commitment.all.each do |commitment|
      user = User.find_by_email!(commitment.participant.email)
      commitment.participant_id = user.id
    end
    rename_column :commitments, :participant_id, :user_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
