class AddSourceToFubLeadData < ActiveRecord::Migration[5.0]
  def change
    add_column :fub_lead_data, :source, :string
  end
end
