class Api::UsersController < Api::BaseController
  def create
    user = User.new(params[:user])
    if user.save
      render_response(user, code: 201)
    else
      render_error(400, user.errors)
    end
  end
end
