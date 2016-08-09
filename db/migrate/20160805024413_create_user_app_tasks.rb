class CreateUserAppTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :user_app_tasks do |t|
      t.integer :user_id
      t.integer :app_task_id

      t.timestamps
    end
  end
end
