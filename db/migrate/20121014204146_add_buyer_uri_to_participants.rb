class AddBuyerUriToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :buyer_uri, :string
  end
end
