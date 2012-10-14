class Api::HiController < Api::BaseController
  skip_before_filter :require_user

  def hi
    render_response(hi: "how are you?")
  end
end
