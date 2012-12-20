class DowncaseUsersEmails < ActiveRecord::Migration
  def up
    execute "update users set email = lower(email)"
  end

  def down
    # nope.
  end
end
