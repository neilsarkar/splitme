class Api::AccessTokensController < Api::BaseController
  skip_before_filter :require_user

  def from_groupme_token
    raise UnauthorizedError unless params[:groupme_token].present?
    converter = UserConverter.new(params[:groupme_token])
    if converter.process
      render_response converter.user
    elsif converter.user.present?
      render_error(400, converter.user.errors)
    else
      head 401
    end
  end
end
