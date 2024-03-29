GroupMe.configure do
  set :application_name, "splitme"
  set :heroku_platform, :cedar

  environment :staging do
    set :heroku_app_name, "splitme-b"
    set :deploy_steps, [
      :deploy!,
      :migrate!
    ]
  end

  environment :production do
    set :heroku_app_name, "splitme"
    set :deploy_steps, [
      :test_suite,
      :maintenance_on,
      :deploy!,
      :migrate!,
      :maintenance_off
    ]
  end
end
