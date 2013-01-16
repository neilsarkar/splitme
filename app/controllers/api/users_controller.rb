class Api::UsersController < Api::BaseController
  skip_before_filter :require_user, only: [:create, :authenticate]

  def create
    user = User.new(user_params)
    if user.save
      render_response(user, code: 201)
    else
      render_error(400, user.errors)
    end
  end

  def authenticate
    user = User.find_by_email!(user_params[:email]).authenticate(user_params[:password])
    if user.present?
      render_response(user)
    else
      raise UnauthorizedError
    end
  end

  def update
    if current_user.update_attributes(user_params)
      render_response(current_user)
    else
      render_error(400, current_user.errors)
    end
  end

  def me
    render_response(current_user)
  end

  private

  def user_params
    @user_params ||= params[:user] || {}
  end
end
