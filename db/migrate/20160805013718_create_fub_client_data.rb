class CreateFubClientData < ActiveRecord::Migration[5.0]
  def change
    create_table :fub_client_data do |t|
      t.string :api_key
      t.integer :user_id
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
