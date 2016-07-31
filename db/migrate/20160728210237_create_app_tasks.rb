class CreateAppTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :app_tasks do |t|
      t.integer :status_identity
      t.timestamp :ran_at
      t.string :name

      t.timestamps
    end
  end
end
