class AddFubLeadToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :fub_lead, :boolean, default: false
  end
end
