class AddCreditUriToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :credit_uri, :string
  end
end
