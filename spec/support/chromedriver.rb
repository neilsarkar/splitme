unless `which chromedriver`
  warning = <<-END
*******************************************************************************

    you need to install chromedriver. go here:

    http://code.google.com/p/chromedriver/downloads/list

*******************************************************************************
  END
  puts warning
  exit!
end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, native_events: true)
end
