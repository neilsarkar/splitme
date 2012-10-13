class Api::BaseController < ApplicationController
  include ApiResponder

  prepend_before_filter :require_user
  skip_before_filter :verify_authenticity_token
  skip_before_filter :adjust_format

  private

  def current_user
    return @current_user if defined?(@current_user)
    params[:token] ||= request.headers["X-Access-Token"]
    @current_user = User.find_by_token(params[:token])
  end

  def require_user
    raise UnauthorizedError unless current_user.present?
  end
end
