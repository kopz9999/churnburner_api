class CreateSyncEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :sync_events do |t|
      t.string :name
      t.string :description
      t.integer :user_id
      t.integer :fub_id
      t.integer :fub_created
      t.boolean :sent_to_intercom, default: false
      t.boolean :received_by_intercom, default: false

      t.timestamps
    end
  end
end
