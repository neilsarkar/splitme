class ReconnectCommitmentsToUsers < ActiveRecord::Migration
  def up
    Commitment.all.each do |commitment|
      participant = Participant.find(commitment.user_id)
      user = User.find_by_email!(participant.email)
      commitment.user_id = user.id
      commitment.save
    end
  end

  def down
  end
end
