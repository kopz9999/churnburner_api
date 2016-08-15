class CreateSidekiqJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :sidekiq_jobs do |t|
      t.string :sidekiq_job_id
      t.integer :job_id
      t.integer :app_task_id

      t.timestamps
    end
  end
end
