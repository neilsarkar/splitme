class ConvertParticipantsToUsers < ActiveRecord::Migration
  def up
    Participant.all.each do |participant|
      balanced_account = Balanced::Account.find_by_email(participant.email)
      user = User.new(
        name: participant.name,
        email: participant.email,
        phone_number: participant.phone_number,
        card_uri: participant.card_uri
      )
      user.balanced_payments_id = balanced_account.id
      user.password = "temporary"
      user.save!
      user.update_attribute :password_digest, participant.password_digest
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
