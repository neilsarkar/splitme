class CreateCommitments < ActiveRecord::Migration
  def change
    create_table :commitments do |t|
      t.integer :participant_id
      t.integer :plan_id

      t.timestamps
    end

    add_index :commitments, :participant_id
    add_index :commitments, :plan_id
  end
end
