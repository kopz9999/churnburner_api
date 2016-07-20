class CreateSegmentUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :segment_users do |t|
      t.integer :segment_id
      t.integer :user_id

      t.timestamps
    end
  end
end
