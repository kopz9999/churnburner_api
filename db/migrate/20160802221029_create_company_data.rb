class CreateCompanyData < ActiveRecord::Migration[5.0]
  def change
    create_table :company_data do |t|
      t.integer :company_id
      t.string :name
      t.string :value

      t.timestamps
    end
  end
end
