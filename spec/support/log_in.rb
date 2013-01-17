module LoginHelper
  def login(user, password)
    visit "/log_in"
    fill_in "js-email", with: user.email
    fill_in "js-password", with: password
    click_button "Log In"
  end
end

RSpec.configuration.include LoginHelper, example_group: {file_path: RSpec.configuration.escaped_path(%w[spec integration])}
