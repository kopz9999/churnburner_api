class CreateFubSources < ActiveRecord::Migration[5.0]
  def change
    create_table :fub_sources do |t|
      t.string :name

      t.timestamps
    end
  end
end
