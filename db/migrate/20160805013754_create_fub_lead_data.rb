class CreateFubLeadData < ActiveRecord::Migration[5.0]
  def change
    create_table :fub_lead_data do |t|
      t.timestamp :converted_at
      t.timestamp :synced_at
      t.integer :sync_status_identity
      t.integer :user_id

      t.timestamps
    end
  end
end
