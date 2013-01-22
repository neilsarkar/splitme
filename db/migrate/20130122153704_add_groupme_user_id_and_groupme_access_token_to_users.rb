class AddGroupmeUserIdAndGroupmeAccessTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :groupme_user_id, :string
    add_column :users, :groupme_access_token, :string
    add_index :users, :groupme_user_id
  end
end
