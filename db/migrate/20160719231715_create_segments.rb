class CreateSegments < ActiveRecord::Migration[5.0]
  def change
    create_table :segments do |t|
      t.string :intercom_id
      t.string :name

      t.timestamps
    end
  end
end
