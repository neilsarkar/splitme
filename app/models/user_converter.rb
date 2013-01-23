class UserConverter
  attr_accessor :user

  def initialize(token)
    @token = token
    @client = GroupmeClient.new(token)
  end

  def process
    response = @client.get("/users/me")
    if response.success?
      user_data = response.response[:user]
      @user = User.find_by_groupme_user_id(user_data["id"])
      create_user(user_data) unless @user
      @user.id.present?
    else
      return false
    end
  end

  private

  def create_user(user_data)
    @user = User.new({
      name:                 user_data["name"],
      email:                user_data["email"],
      phone_number:         user_data["phone_number"]
    })
    @user.groupme_user_id = user_data["id"]
    @user.groupme_access_token = @token
    @user.save
  end
end
