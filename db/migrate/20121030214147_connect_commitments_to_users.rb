class ConnectCommitmentsToUsers < ActiveRecord::Migration
  def up
    rename_column :commitments, :participant_id, :user_id
  end

  def down
    rename_column :commitments, :user_id, :participant_id
  end
end
