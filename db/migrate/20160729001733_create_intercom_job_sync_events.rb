class CreateIntercomJobSyncEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :intercom_job_sync_events do |t|
      t.integer :intercom_job_id
      t.integer :sync_event_id

      t.timestamps
    end
  end
end
