class AddDefaultToUserCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :user_companies, :default, :boolean, default: false
  end
end
