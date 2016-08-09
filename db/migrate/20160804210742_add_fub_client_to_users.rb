class AddFubClientToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :fub_client, :boolean, default: false
  end
end
