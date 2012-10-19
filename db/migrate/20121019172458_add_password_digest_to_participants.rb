class AddPasswordDigestToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :password_digest, :string
  end
end
