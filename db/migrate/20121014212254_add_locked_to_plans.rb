class AddLockedToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :locked, :boolean
  end
end
