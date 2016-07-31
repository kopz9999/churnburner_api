class CreateIntercomJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :intercom_jobs do |t|
      t.string :intercom_id
      t.integer :type_identity
      t.integer :status_identity

      t.timestamps
    end
  end
end
