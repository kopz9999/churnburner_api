class AddFubIdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :fub_id, :integer
  end
end
